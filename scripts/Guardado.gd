class_name Guardado


const RUTA = "user://partida_guardada.json"
const VERSION = 1


static func existe() -> bool:
	return FileAccess.file_exists(RUTA)


static func borrar() -> void:
	if existe():
		DirAccess.remove_absolute(RUTA)


# Devuelve false si no se pudo guardar.
static func guardar(partida: Partida) -> bool:
	var archivo := FileAccess.open(RUTA, FileAccess.WRITE)

	if archivo == null:
		return false

	archivo.store_string(JSON.stringify(_a_diccionario(partida), "\t"))
	archivo.close()

	return true


# Devuelve null si el archivo no existe, no se puede leer o los datos
# no son validos.
static func cargar() -> Partida:
	if not existe():
		return null

	var archivo := FileAccess.open(RUTA, FileAccess.READ)

	if archivo == null:
		return null

	var texto: String = archivo.get_as_text()
	archivo.close()

	var json := JSON.new()

	if json.parse(texto) != OK:
		return null

	if not (json.data is Dictionary):
		return null

	return _desde_diccionario(json.data)


# ---------- Guardado ----------

static func _carta_a_diccionario(carta: Carta) -> Dictionary:
	return {
		"palo": int(carta.palo),
		"valor": carta.valor,
		"visible": carta.visible
	}


static func _a_diccionario(partida: Partida) -> Dictionary:
	var columnas: Array = []

	for columna in partida.columnas:
		var lista_columna: Array = []

		for carta in columna.cartas:
			lista_columna.append(_carta_a_diccionario(carta))

		columnas.append(lista_columna)

	var fundaciones: Array = []

	for fundacion in partida.fundaciones:
		var lista_fundacion: Array = []

		for carta in fundacion.cartas:
			lista_fundacion.append(_carta_a_diccionario(carta))

		fundaciones.append(lista_fundacion)

	var cartas_mano: Array = []

	for carta in partida.mano.cartas:
		cartas_mano.append(_carta_a_diccionario(carta))

	return {
		"version": VERSION,
		"columnas": columnas,
		"fundaciones": fundaciones,
		"mano": {
			"cartas": cartas_mano,
			"criterio": int(partida.mano.criterio_ordenamiento),
			"palo_seleccionado": int(partida.mano.palo_seleccionado),
			"rojas_primero": partida.mano.rojas_primero
		}
	}


# ---------- Carga y validacion ----------

# JSON entrega los numeros como decimales (5.0): se aceptan si son enteros.
static func _es_entero(valor: Variant) -> bool:
	if typeof(valor) == TYPE_INT:
		return true

	if typeof(valor) == TYPE_FLOAT:
		return valor == floor(valor)

	return false


static func _entero_en_rango(valor: Variant, minimo: int, maximo: int) -> bool:
	if not _es_entero(valor):
		return false

	return int(valor) >= minimo and int(valor) <= maximo


# "vistas" registra las cartas ya usadas para detectar repetidas.
static func _crear_carta(dato: Variant, vistas: Dictionary) -> Carta:
	if not (dato is Dictionary):
		return null

	if not _entero_en_rango(dato.get("palo"), 0, 3):
		return null

	if not _entero_en_rango(dato.get("valor"), 1, 13):
		return null

	if typeof(dato.get("visible")) != TYPE_BOOL:
		return null

	var palo: int = int(dato["palo"])
	var valor: int = int(dato["valor"])
	var identificador: int = palo * 13 + valor - 1

	if vistas.has(identificador):
		return null

	vistas[identificador] = true

	return Carta.new(palo as Carta.Palo, valor, dato["visible"])


static func _desde_diccionario(datos: Dictionary) -> Partida:
	if not _entero_en_rango(datos.get("version"), VERSION, VERSION):
		return null

	var columnas: Variant = datos.get("columnas")
	var fundaciones: Variant = datos.get("fundaciones")
	var datos_mano: Variant = datos.get("mano")

	if not (columnas is Array) or columnas.size() != 7:
		return null

	if not (fundaciones is Array) or fundaciones.size() != 4:
		return null

	if not (datos_mano is Dictionary):
		return null

	var partida := Partida.new()
	var vistas: Dictionary = {}

	# Columnas: las ocultas solo pueden estar debajo de las visibles y
	# la carta superior de una columna con cartas debe estar visible.
	for numero in range(7):
		if not (columnas[numero] is Array):
			return null

		var hay_visible: bool = false

		for dato in columnas[numero]:
			var carta: Carta = _crear_carta(dato, vistas)

			if carta == null:
				return null

			if carta.visible:
				hay_visible = true
			elif hay_visible:
				return null

			partida.columnas[numero].cartas.append(carta)

		var cartas_columna: Array[Carta] = partida.columnas[numero].cartas

		if not cartas_columna.is_empty() and not cartas_columna.back().visible:
			return null

	# Fundaciones: cada una debe ser una secuencia valida (As, luego el
	# siguiente valor del mismo palo). Se reutiliza la regla de Fundacion.
	for numero in range(4):
		if not (fundaciones[numero] is Array):
			return null

		for dato in fundaciones[numero]:
			var carta_fundacion: Carta = _crear_carta(dato, vistas)

			if carta_fundacion == null or not carta_fundacion.visible:
				return null

			if not partida.fundaciones[numero].agregar_carta(carta_fundacion):
				return null

	# Mano
	if not (datos_mano.get("cartas") is Array):
		return null

	if not _entero_en_rango(datos_mano.get("criterio"), 0, 3):
		return null

	if not _entero_en_rango(datos_mano.get("palo_seleccionado"), 0, 3):
		return null

	if typeof(datos_mano.get("rojas_primero")) != TYPE_BOOL:
		return null

	for dato in datos_mano["cartas"]:
		var carta_mano: Carta = _crear_carta(dato, vistas)

		if carta_mano == null or not carta_mano.visible:
			return null

		partida.mano.cartas.append(carta_mano)

	partida.mano.criterio_ordenamiento = int(datos_mano["criterio"]) as Mano.Criterio
	partida.mano.palo_seleccionado = int(datos_mano["palo_seleccionado"]) as Carta.Palo
	partida.mano.rojas_primero = datos_mano["rojas_primero"]

	# Tienen que estar las 52 cartas, sin repetir ni faltar.
	if vistas.size() != 52:
		return null

	return partida
