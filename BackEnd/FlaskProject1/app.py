############################################################
#                    IMPORTACIONS                          #
############################################################
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from datetime import datetime
import csv
import json
from shapely.geometry import shape, Point
from shapely.errors import GEOSException
import requests
from flask import Response

############################################################
#              CONFIGURACIÓ FLASK I CONNEXIÓ MONGO         #
############################################################
app = Flask(__name__)
CORS(app)

db_uri = "mongodb://localhost"
client = MongoClient(db_uri)
db = client['tfg']

############################################################
#                    COL·LECCIONS                          #
############################################################
usuaris = db['usuaris']
comarques = db['comarques']
punts_historics = db['punts_historics']
fotos = db['fotos']
conquestes_punts = db['conquestes_punts']
conquestes_comarques = db['conquestes_comarques']

############################################################
#                  FUNCIONS AUXILIARS                      #
############################################################

def inserir_comarques():
    if comarques.count_documents({}) > 0:
        print("Les comarques ja estaven inserides.")
        return

    with open("divisions-comarques.json", "r", encoding="utf-8") as f:
        dades = json.load(f)

    noms = set()
    for comarca in dades["features"]:
        nom = comarca["properties"].get("NOMCOMAR")
        if nom:
            noms.add(nom)

    documents = [{"nom": nom} for nom in sorted(noms)]
    resultat = comarques.insert_many(documents)
    print(f"S'han inserit {len(resultat.inserted_ids)} comarques correctament.")

def inserir_punts_historics():
    if punts_historics.count_documents({}) > 0:
        print("Els punts històrics ja estaven inserits.")
        return

    with open("localitzacions.json", "r", encoding="utf-8") as f:
        localitzacions = json.load(f)

    with open("fotografies_historiques.tsv", "r", encoding="utf-8") as f:
        lector = csv.DictReader(f, delimiter="\t")
        punts = {}
        for fila in lector:
            loc = fila["locs"]
            if loc not in localitzacions:
                continue

            if loc not in punts:
                punts[loc] = {
                    "nom": loc,
                    "coordenades": {
                        "type": "Point",
                        "coordinates": [localitzacions[loc]["latlong"][1], localitzacions[loc]["latlong"][0]]
                    },
                    "descripcio": localitzacions[loc].get("address", ""),
                    "comarca_id": None,
                    "foto_urls": []
                }

            punts[loc]["foto_urls"].append(fila["url"])

    documents = list(punts.values())
    resultats = punts_historics.insert_many(documents)
    print(f"{len(resultats.inserted_ids)} punts històrics inserits.")

def inserir_fotografies_historiques():
    if fotos.count_documents({}) > 0:
        print("Les fotografies històriques ja estaven inserides.")
        return

    punts = {punt["nom"]: punt["_id"] for punt in punts_historics.find({}, {"nom": 1})}

    with open("fotografies_historiques.tsv", "r", encoding="utf-8") as f:
        lector = csv.DictReader(f, delimiter="\t")
        fotos_docs = []
        for fila in lector:
            loc = fila["locs"]
            if loc not in punts:
                continue

            fotos_docs.append({
                "tipus": "històrica",
                "punt_id": punts[loc],
                "foto_url": fila["url"],
                "descripcio": fila["descs"]
            })

    if fotos_docs:
        resultats = fotos.insert_many(fotos_docs)
        print(f"{len(resultats.inserted_ids)} fotografies històriques inserides.")

def assignar_comarques_a_punts():
    with open("divisions-comarques.json", "r", encoding="utf-8") as f:
        geojson = json.load(f)

    comarques_shapes = []
    for feature in geojson["features"]:
        try:
            nom = feature["properties"]["NOMCOMAR"]
            geom = shape(feature["geometry"]).buffer(0)
            bounds = geom.bounds
            comarques_shapes.append((nom, geom, bounds))
        except Exception as e:
            print(f"Error processant comarca {feature['properties'].get('NOMCOMAR', 'desconeguda')}: {e}")

    comarca_to_id = {doc["nom"]: doc["_id"] for doc in comarques.find({}, {"nom": 1})}

    actualitzats = 0
    for punt in punts_historics.find({
        "$or": [
            {"comarca_id": None},
            {"comarca_nom": {"$exists": False}}
        ]
    }):
        coords = punt["coordenades"]["coordinates"]
        punt_shape = Point(coords)

        comarca_id = None
        comarca_nom = None
        min_dist = float('inf')

        for c_nom, c_geom, (minx, miny, maxx, maxy) in comarques_shapes:
            try:
                if not (minx <= coords[0] <= maxx and miny <= coords[1] <= maxy):
                    continue

                if c_geom.contains(punt_shape):
                    comarca_id = comarca_to_id.get(c_nom)
                    comarca_nom = c_nom
                    break

                dist = punt_shape.distance(c_geom)
                if dist < min_dist:
                    comarca_id = comarca_to_id.get(c_nom)
                    comarca_nom = c_nom
                    min_dist = dist
            except GEOSException as e:
                print(f"Error amb la geometria de {c_nom}: {e}")

        if comarca_id and comarca_nom:
            punts_historics.update_one(
                {"_id": punt["_id"]},
                {"$set": {
                    "comarca_id": comarca_id,
                    "comarca_nom": comarca_nom
                }}
            )
            actualitzats += 1

    print(f"S'han actualitzat {actualitzats} punts històrics amb la seva comarca.")

def obtenir_punts_per_comarca():
    resultats = list(punts_historics.aggregate([
        {"$match": {"comarca_id": {"$ne": None}}},
        {"$group": {"_id": "$comarca_id", "count": {"$sum": 1}}}
    ]))

    comarca_id_to_nom = {str(doc["_id"]): doc["nom"] for doc in comarques.find({})}

    llista = []
    for resultat in resultats:
        comarca_id = str(resultat["_id"])
        nom_comarca = comarca_id_to_nom.get(comarca_id, "Desconeguda")
        llista.append({"comarca": nom_comarca, "punts": resultat["count"]})

    return llista

def obtenir_municipis_no_assignats():
    municipis = []
    for punt in punts_historics.find({"comarca_id": None}, {"nom": 1}):
        municipis.append(punt["nom"])
    municipis_uniques = sorted(set(municipis))
    return municipis_uniques

############################################################
#                    RUTES USUARIS                         #
############################################################

@app.route('/nou_usuari', methods=['POST'])
def crear_usuari():
    data = request.get_json()
    nom = data.get("nom", "").strip()
    codi_usuari = data.get("codi_usuari", "").strip()

    if not nom or not codi_usuari:
        return jsonify({"status": "error", "message": "Nom i codi requerits"}), 400

    if usuaris.find_one({"codi_usuari": codi_usuari}):
        return jsonify({"status": "error", "message": "Aquest codi ja existeix"}), 409

    nou_usuari = {
        "codi_usuari": codi_usuari,
        "nom": nom,
        "data_creacio": datetime.now()
    }

    result = usuaris.insert_one(nou_usuari)

    return jsonify({
        "status": "success",
        "usuari_id": str(result.inserted_id),
        "codi_usuari": codi_usuari
    })

@app.route('/existeix_usuari/<codi_usuari>', methods=['GET'])
def verificar_usuari(codi_usuari):
    if not codi_usuari or len(codi_usuari) != 14 or codi_usuari[4] != '-' or codi_usuari[9] != '-':
        return jsonify({"status": "error", "message": "Format incorrecte"}), 400

    usuari = usuaris.find_one({"codi_usuari": codi_usuari})
    return jsonify({"status": "success", "existeix": bool(usuari)})

@app.route('/usuaris', methods=['GET'])
@app.route('/usuaris/', methods=['GET'])
def obtenir_usuaris():
    tots_usuaris = usuaris.find({}, {'_id': 0})
    return jsonify(list(tots_usuaris))

############################################################
#                    RUTES COMARQUES                       #
############################################################

@app.route('/comarques', methods=['GET'])
@app.route('/comarques/', methods=['GET'])
def obtenir_comarques():
    totes = comarques.find({}, {'_id': 0})
    return jsonify(list(totes))

@app.route('/comarca', methods=['GET'])
def obtenir_comarca_per_coordenades():
    try:
        lat = float(request.args.get('lat'))
        lon = float(request.args.get('lon'))
    except (TypeError, ValueError):
        return jsonify({"error": "Paràmetres invàlids"}), 400

    punt = Point(lon, lat)

    with open("divisions-comarques.json", "r", encoding="utf-8") as f:
        geojson = json.load(f)

    for feature in geojson["features"]:
        try:
            nom = feature["properties"]["NOMCOMAR"]
            geom = shape(feature["geometry"]).buffer(0)
            if geom.contains(punt):
                return jsonify({"comarca": nom})
        except Exception as e:
            print(f"Error amb la geometria: {e}")
            continue

    return jsonify({"comarca": "Desconeguda"})

@app.route('/bounds_comarca/<nom>', methods=['GET'])
def obtenir_bounds_comarca(nom):
    with open("divisions-comarques.json", "r", encoding="utf-8") as f:
        dades = json.load(f)

    for feature in dades["features"]:
        if feature["properties"].get("NOMCOMAR") == nom:
            geom = shape(feature["geometry"])
            minx, miny, maxx, maxy = geom.bounds
            return jsonify({
                "minLat": miny,
                "minLng": minx,
                "maxLat": maxy,
                "maxLng": maxx
            })

    return jsonify({"error": "Comarca no trobada"}), 404

############################################################
#                    RUTES PUNTS HISTÒRICS                 #
############################################################

@app.route('/punts', methods=['GET'])
@app.route('/punts/', methods=['GET'])
def obtenir_punts():
    punts = punts_historics.find({})
    llista = []
    for punt in punts:
        punt['_id'] = str(punt['_id'])
        if 'comarca_id' in punt and punt['comarca_id'] is not None:
            punt['comarca_id'] = str(punt['comarca_id'])
        llista.append(punt)
    return jsonify(llista)

@app.route('/punts_hist', methods=['GET'])
def obtenir_punts_hist():
    punts = punts_historics.find({}, {"_id": 0})
    return jsonify(list(punts))

@app.route('/punts_per_comarca', methods=['GET'])
def punts_per_comarca():
    return jsonify(obtenir_punts_per_comarca())

@app.route('/punts_comarca/<nom_comarca>', methods=['GET'])
def obtenir_punts_comarca_per_nom(nom_comarca):
    punts = list(punts_historics.find({'comarca_nom': nom_comarca}))

    for punt in punts:
        punt['_id'] = str(punt['_id'])  # transforma l'ObjectId principal
        if 'comarca_id' in punt and punt['comarca_id'] is not None:
            punt['comarca_id'] = str(punt['comarca_id'])  # també aquest camp
        # opcionalment, si tens altres ObjectIds com punt_id dins de fotos, converteix-los aquí també

    return jsonify(punts)

@app.route("/debug_punts_comarques")
def debug_punts_comarques():
    from collections import defaultdict
    agrupats = defaultdict(list)

    for punt in punts_historics.find():
        comarca = punt.get("comarca_nom", "Sense comarca")
        agrupats[comarca].append(punt.get("nom", "Sense nom"))

    resultat = {comarca: municipis for comarca, municipis in agrupats.items()}
    return jsonify(resultat)

@app.route('/municipis_no_assignats', methods=['GET'])
def municipis_no_assignats():
    return jsonify(obtenir_municipis_no_assignats())

############################################################
#              RUTA CONQUESTES PER USUARI                  #
############################################################

@app.route('/conquestes_punts/<codi_usuari>', methods=['GET'])
def obtenir_conquestes_punts(codi_usuari):
    conquestes = conquestes_punts.find({"codi_usuari": codi_usuari}, {"_id": 0, "punt_id": 1})
    ids = [c["punt_id"] for c in conquestes]
    return jsonify(ids)

@app.route('/resum_conquestes/<codi_usuari>', methods=['GET'])
def resum_conquestes(codi_usuari):
    conquestes = conquestes_punts.find({"codi_usuari": codi_usuari})
    punt_ids = [c["punt_id"] for c in conquestes]

    punts = punts_historics.find({"nom": {"$in": punt_ids}})
    comarca_conquestes = {}
    for punt in punts:
        comarca_id = punt.get("comarca_id")
        if comarca_id:
            comarca_conquestes[comarca_id] = comarca_conquestes.get(comarca_id, 0) + 1

    comarques_conquerides = sum(1 for v in comarca_conquestes.values() if v >= 5)
    punts_conquerits = len(punt_ids)

    return jsonify({
        "comarques_conquerides": comarques_conquerides,
        "punts_conquerits": punts_conquerits
    })

@app.route('/conquerir_punt', methods=['POST'])
def conquerir_punt():
    data = request.get_json()
    codi_usuari = data.get("codi_usuari")
    punt_id = data.get("punt_id")
    foto_base64 = data.get("foto_base64")

    if not codi_usuari or not punt_id or not foto_base64:
        return jsonify({"error": "Falten paràmetres"}), 400

    # Evitar duplicats
    existent = conquestes_punts.find_one({"codi_usuari": codi_usuari, "punt_id": punt_id})
    if existent:
        return jsonify({"status": "ja conquerit"}), 200

    # Inserim la foto base64 i obtenim el seu ID
    foto_doc = {
        "tipus": "usuari",
        "punt_id": punt_id,
        "foto_base64": foto_base64,
        "codi_usuari": codi_usuari,
        "data": datetime.now()
    }
    foto_resultat = fotos.insert_one(foto_doc)
    foto_id = foto_resultat.inserted_id

    # Inserim la conquesta amb referència a la foto
    conquestes_punts.insert_one({
        "codi_usuari": codi_usuari,
        "punt_id": punt_id,
        "foto_id": foto_id,
        "data_conquesta": datetime.now()
    })

    return jsonify({"status": "conquesta registrada"})

@app.route('/punts_conquerits_comarca/<codi_usuari>', methods=['GET'])
def punts_conquerits_comarca(codi_usuari):
    conquestes = conquestes_punts.find({"codi_usuari": codi_usuari})
    punt_ids = [c["punt_id"] for c in conquestes]

    # Busquem pels noms dels punts conquerits
    punts = punts_historics.find({"nom": {"$in": punt_ids}})
    comarca_conquestes = {}
    for punt in punts:
        nom_comarca = punt.get("comarca_nom")
        if nom_comarca:
            comarca_conquestes[nom_comarca] = comarca_conquestes.get(nom_comarca, 0) + 1

    return jsonify(comarca_conquestes)

@app.route('/ranking', methods=['GET'])
def obtenir_ranking():
    usuaris_cursor = usuaris.find({}, {'_id': 0, 'codi_usuari': 1, 'nom': 1})
    usuaris_llista = list(usuaris_cursor)

    ranking = []

    for usuari in usuaris_llista:
        codi = usuari['codi_usuari']
        nom = usuari.get('nom', 'Anònim')

        conquestes = conquestes_punts.find({"codi_usuari": codi})
        punt_ids = [c["punt_id"] for c in conquestes]

        punts = punts_historics.find({"nom": {"$in": punt_ids}})
        comarca_counts = {}
        for punt in punts:
            comarca_id = punt.get("comarca_id")
            if comarca_id:
                comarca_counts[comarca_id] = comarca_counts.get(comarca_id, 0) + 1

        comarques_conquerides = sum(1 for v in comarca_counts.values() if v >= 5)
        punts_conquerits = len(punt_ids)

        ranking.append({
            "codi_usuari": codi,
            "nom": nom,
            "comarques": comarques_conquerides,
            "punts": punts_conquerits,
        })

    ranking_ordenat = sorted(
        ranking,
        key=lambda x: (-x["comarques"], -x["punts"])
    )

    return jsonify(ranking_ordenat)

############################################################
#                    RUTES FOTOGRAFIES                     #
############################################################

@app.route('/fotografies', methods=['GET'])
@app.route('/fotografies/', methods=['GET'])
def obtenir_fotografies():
    totes = fotos.find({}, {'_id': 0})
    fotografies_list = []
    for foto in totes:
        foto['punt_id'] = str(foto['punt_id'])
        fotografies_list.append(foto)
    return jsonify(fotografies_list)

@app.route('/proxy_imatge')
def proxy_imatge():
    url = request.args.get('url')
    if not url:
        return jsonify({'error': 'Falta el paràmetre url'}), 400

    try:
        r = requests.get(url, stream=True, timeout=10)
        r.raise_for_status()
        content_type = r.headers.get('Content-Type', 'image/jpeg')
        return Response(r.content, content_type=content_type)
    except Exception as e:
        print(f"Error carregant imatge: {e}")
        return jsonify({'error': 'No s’ha pogut carregar la imatge'}), 500

############################################################
#                    EXECUCIÓ PRINCIPAL                    #
############################################################

if __name__ == "__main__":
    #inserir_comarques()
    #inserir_punts_historics()
    #inserir_fotografies_historiques()
    #assignar_comarques_a_punts()
    #app.run(host="0.0.0.0")
    app.run(debug=True)
