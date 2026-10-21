class_name Analizador


enum Resultado {
	HAY_PROGRESO,
	SIN_PROGRESO,
	INDETERMINADO
}

# Tope de posiciones a explorar. Si se supera, no se afirma nada
# (la partida NO se da por bloqueada).
const LIMITE_ESTADOS = 30000


static func esta_completa(partida: Partida) -> bool:
	for fundacion in partida.fundaciones:
		if not fundacion.esta_completa():
			return false

	return true


static func analizar(partida: Partida) -> Dictionary:
	var inicial: Dictionary = _crear_estado(partida)
	var ocultas_iniciales: int = _total(inicial["oc"])
	var fundacion_inicial: int = _total(inicial["fund"])

	var visitados: Dictionary = {_clave(inicial): true}
	var cola: Array = [inicial]
	var indice: int = 0

	while indice < cola.size():
		var estado: Dictionary = cola[indice]
		indice += 1

		for sucesor in _sucesores(estado):
			if _total(sucesor["oc"]) < ocultas_iniciales \
			or _total(sucesor["fund"]) > fundacion_inicial:
				return {
					"resultado": Resultado.HAY_PROGRESO,
					"estados": visitados.size()
				}

			var clave: String = _clave(sucesor)

			if visitados.has(clave):
				continue

			visitados[clave] = true
			cola.append(sucesor)

			if visitados.size() > LIMITE_ESTADOS:
				return {
					"resultado": Resultado.INDETERMINADO,
					"estados": visitados.size()
				}

	return {
		"resultado": Resultado.SIN_PROGRESO,
		"estados": visitados.size()
	}


# ---------- Representacion compacta del estado ----------
# "col":  por columna, la lista de cartas (de abajo hacia arriba)
# "oc":   por columna, cuantas cartas ocultas tiene (siempre las de abajo)
# "mano": mascara de bits con las cartas que siguen en la mano
# "fund": cantidad de cartas de cada palo en las fundaciones
# Cada carta es un numero: palo * 13 + valor - 1

static func _id(carta: Carta) -> int:
	return int(carta.palo) * 13 + carta.valor - 1


static func _palo(id_carta: int) -> int:
	return floori(id_carta / 13.0)


static func _valor(id_carta: int) -> int:
	return id_carta % 13 + 1


static func _es_roja(id_carta: int) -> bool:
	return _palo(id_carta) <= Carta.Palo.DIAMANTES


static func _crear_estado(partida: Partida) -> Dictionary:
	var columnas: Array = []
	var ocultas: Array = []

	for columna in partida.columnas:
		var ids: Array = []
		var cantidad_ocultas: int = 0

		for carta in columna.cartas:
			ids.append(_id(carta))

			if not carta.visible:
				cantidad_ocultas += 1

		columnas.append(ids)
		ocultas.append(cantidad_ocultas)

	var mascara_mano: int = 0

	for carta in partida.mano.cartas:
		mascara_mano |= 1 << _id(carta)

	var fundaciones: Array = [0, 0, 0, 0]

	for fundacion in partida.fundaciones:
		if not fundacion.cartas.is_empty():
			var palo_fundacion: int = int(fundacion.cartas[0].palo)
			fundaciones[palo_fundacion] = fundacion.cartas.size()

	return {
		"col": columnas,
		"oc": ocultas,
		"mano": mascara_mano,
		"fund": fundaciones
	}


static func _copiar(estado: Dictionary) -> Dictionary:
	return {
		"col": estado["col"].duplicate(true),
		"oc": estado["oc"].duplicate(),
		"mano": estado["mano"],
		"fund": estado["fund"].duplicate()
	}


static func _total(lista: Array) -> int:
	var suma: int = 0

	for elemento in lista:
		suma += elemento

	return suma


static func _clave(estado: Dictionary) -> String:
	var partes := PackedStringArray()

	for i in range(estado["col"].size()):
		var texto: String = str(estado["oc"][i]) + ":"

		for carta in estado["col"][i]:
			texto += str(carta) + ","

		partes.append(texto)

	# Las columnas son intercambiables: se ordenan para que dos estados
	# iguales salvo por el orden de las columnas cuenten como uno solo.
	partes.sort()

	return (
		"|".join(partes)
		+ "#" + str(estado["mano"])
		+ "#" + str(estado["fund"])
	)


# ---------- Reglas ----------

static func _consecutivas(mayor: int, menor: int) -> bool:
	return (
		_valor(mayor) == _valor(menor) + 1
		and _es_roja(mayor) != _es_roja(menor)
	)


static func _puede_colocar(carta: int, destino: Array) -> bool:
	if destino.is_empty():
		return _valor(carta) == 13

	return _consecutivas(destino[destino.size() - 1], carta)


static func _revelar_si_corresponde(estado: Dictionary, columna: int) -> void:
	var cantidad: int = estado["col"][columna].size()

	if cantidad > 0 and estado["oc"][columna] >= cantidad:
		estado["oc"][columna] = cantidad - 1


# ---------- Movimientos posibles desde un estado ----------

static func _sucesores(estado: Dictionary) -> Array:
	var resultado: Array = []
	var columnas: Array = estado["col"]
	var ocultas: Array = estado["oc"]
	var mano: int = estado["mano"]
	var fund: Array = estado["fund"]

	# Desde las columnas
	for origen in range(columnas.size()):
		var col: Array = columnas[origen]
		var n: int = col.size()

		if n == 0:
			continue

		# Carta superior hacia su fundacion
		var superior: int = col[n - 1]
		var palo_superior: int = _palo(superior)

		if _valor(superior) == fund[palo_superior] + 1:
			var s_fundacion: Dictionary = _copiar(estado)
			s_fundacion["col"][origen].pop_back()
			s_fundacion["fund"][palo_superior] += 1
			_revelar_si_corresponde(s_fundacion, origen)
			resultado.append(s_fundacion)

		# Secuencias visibles hacia otras columnas
		var inicio: int = n - 1

		while inicio >= ocultas[origen]:
			var primera: int = col[inicio]

			for destino in range(columnas.size()):
				if destino == origen:
					continue

				if _puede_colocar(primera, columnas[destino]):
					var s_columna: Dictionary = _copiar(estado)
					var movidas: Array = s_columna["col"][origen].slice(inicio)
					s_columna["col"][origen].resize(inicio)
					s_columna["col"][destino].append_array(movidas)
					_revelar_si_corresponde(s_columna, origen)
					resultado.append(s_columna)

			if inicio == 0:
				break

			# Solo se puede seguir tomando cartas si forman secuencia.
			if not _consecutivas(col[inicio - 1], col[inicio]):
				break

			inicio -= 1

	# Desde la mano
	for id_carta in range(52):
		if ((mano >> id_carta) & 1) == 0:
			continue

		var mano_sin_carta: int = mano ^ (1 << id_carta)
		var palo_mano: int = _palo(id_carta)

		if _valor(id_carta) == fund[palo_mano] + 1:
			var s_mano_fund: Dictionary = _copiar(estado)
			s_mano_fund["mano"] = mano_sin_carta
			s_mano_fund["fund"][palo_mano] += 1
			resultado.append(s_mano_fund)

		for destino in range(columnas.size()):
			if _puede_colocar(id_carta, columnas[destino]):
				var s_mano_col: Dictionary = _copiar(estado)
				s_mano_col["mano"] = mano_sin_carta
				s_mano_col["col"][destino].append(id_carta)
				resultado.append(s_mano_col)

	# Devolver la carta superior de una fundacion a una columna
	for palo_f in range(4):
		if fund[palo_f] == 0:
			continue

		var carta_f: int = palo_f * 13 + fund[palo_f] - 1

		for destino in range(columnas.size()):
			if _puede_colocar(carta_f, columnas[destino]):
				var s_retorno: Dictionary = _copiar(estado)
				s_retorno["fund"][palo_f] -= 1
				s_retorno["col"][destino].append(carta_f)
				resultado.append(s_retorno)

	return resultado
