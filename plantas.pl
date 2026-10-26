% ==============================================================================
% SISTEMA EXPERTO: TAXONOMIA Y VIABILIDAD AMBIENTAL (LOGICA DECLARATIVA)
% Autora: Neshmi Natalia Nolasco Quezada | ESCOM IPN
% Paradigmas de Programacion
%
% Contenido:
%   1. Hechos base (20 especies) y atributos
%   2. Taxonomia derivada (familia, genero)
%   3. Motor de recomendacion con puntaje ponderado (logica difusa discreta)
%   4. Seguridad con negacion por falla (\+)
%   5. Asociaciones entre plantas + busqueda recursiva de caminos
%   6. Diagnostico fitosanitario multi-sintoma con nivel de confianza
% ==============================================================================

:- discontiguous uso/2.

% ------------------------------------------------------------------------------
% 1. HECHOS BASE: optima(Nombre, Especie, Luz, Humedad, Follaje)
% ------------------------------------------------------------------------------
optima(almedro,     amygdalus_communis,      mucha_luz, poca,      tiene_moderada).
optima(cipres,      austrocedrus_chilensis,  mucha_luz, moderada,  tiene_muchas).
optima(baobab,      adansonia_digitata,      mucha_luz, poca,      tiene_pocas).
optima(papiro,      cyperus_papyrus,         mucha_luz, muy_alta,  tiene_pocas).
optima(arce,        acer_palmatum,           mucha_luz, muy_alta,  tiene_muchas).
optima(amapola,     papaver_somniferum,      mucha_luz, poca,      tiene_moderada).
optima(margarita,   bellis_perennis,         poca_luz,  moderada,  tiene_muchas).
optima(hierbabuena, mentha_spicata,          mucha_luz, muy_alta,  tiene_muchas).
optima(remolacha,   beta_vulgaris,           mucha_luz, moderada,  tiene_moderada).
optima(ceiba,       ceiba_pentandra,         mucha_luz, moderada,  tiene_muchas).
optima(pino,        pinus_nigra,             mucha_luz, moderada,  tiene_muchas).
optima(toloache,    datura_stramonium,       mucha_luz, moderada,  tiene_moderada).
optima(neem,        azadirachta_indica,      mucha_luz, moderada,  tiene_moderada).
optima(marihuana,   cannabis_sativa,         mucha_luz, moderada,  tiene_muchas).
optima(epazote,     dysphania_ambrosioides,  poca_luz,  moderada,  tiene_muchas).
optima(mandarino,   citrus_reticulata,       mucha_luz, moderada,  tiene_muchas).
optima(albahaca,    ocimum_basilicum,        mucha_luz, moderada,  tiene_muchas).
optima(alcachofera, cynara_scolymus,         mucha_luz, moderada,  tiene_moderada).
optima(chayote,     sechium_edule,           mucha_luz, muy_alta,  tiene_muchas).
optima(pina,        ananas_comosus,          mucha_luz, moderada,  tiene_moderada).

% Familia botanica
familia(almedro, rosaceae).        familia(cipres, cupressaceae).
familia(baobab, malvaceae).        familia(papiro, cyperaceae).
familia(arce, sapindaceae).        familia(amapola, papaveraceae).
familia(margarita, asteraceae).    familia(hierbabuena, lamiaceae).
familia(remolacha, amaranthaceae). familia(ceiba, malvaceae).
familia(pino, pinaceae).           familia(toloache, solanaceae).
familia(neem, meliaceae).          familia(marihuana, cannabaceae).
familia(epazote, amaranthaceae).   familia(mandarino, rutaceae).
familia(albahaca, lamiaceae).      familia(alcachofera, asteraceae).
familia(chayote, cucurbitaceae).   familia(pina, bromeliaceae).

% Forma de vida
tipo(almedro, arbol).      tipo(cipres, arbol).       tipo(baobab, arbol).
tipo(papiro, acuatica).    tipo(arce, arbol).         tipo(amapola, herbacea).
tipo(margarita, herbacea). tipo(hierbabuena, aromatica). tipo(remolacha, hortaliza).
tipo(ceiba, arbol).        tipo(pino, arbol).         tipo(toloache, herbacea).
tipo(neem, arbol).         tipo(marihuana, herbacea). tipo(epazote, aromatica).
tipo(mandarino, frutal).   tipo(albahaca, aromatica). tipo(alcachofera, hortaliza).
tipo(chayote, trepadora).  tipo(pina, frutal).

% Tamano adulto (grande / mediano / pequeno)
tamano(almedro, mediano).  tamano(cipres, grande).    tamano(baobab, grande).
tamano(papiro, mediano).   tamano(arce, mediano).     tamano(amapola, pequeno).
tamano(margarita, pequeno). tamano(hierbabuena, pequeno). tamano(remolacha, pequeno).
tamano(ceiba, grande).     tamano(pino, grande).      tamano(toloache, mediano).
tamano(neem, grande).      tamano(marihuana, mediano). tamano(epazote, pequeno).
tamano(mandarino, mediano). tamano(albahaca, pequeno). tamano(alcachofera, mediano).
tamano(chayote, mediano).  tamano(pina, pequeno).

% Usos
uso(almedro, comestible).
uso(cipres, ornamental).
uso(baobab, ornamental).     uso(baobab, comestible).
uso(papiro, ornamental).     uso(papiro, industrial).
uso(arce, ornamental).
uso(amapola, medicinal).
uso(margarita, ornamental).  uso(margarita, comestible).
uso(hierbabuena, aromatica). uso(hierbabuena, comestible). uso(hierbabuena, medicinal).
uso(remolacha, comestible).
uso(ceiba, ornamental).      uso(ceiba, industrial).
uso(pino, ornamental).       uso(pino, industrial).
uso(toloache, medicinal).
uso(neem, medicinal).
uso(marihuana, medicinal).   uso(marihuana, industrial).
uso(epazote, aromatica).     uso(epazote, comestible).  uso(epazote, medicinal).
uso(mandarino, comestible).
uso(albahaca, aromatica).    uso(albahaca, comestible).
uso(alcachofera, comestible). uso(alcachofera, medicinal).
uso(chayote, comestible).
uso(pina, comestible).

% Advertencias de seguridad / regulacion
toxica(toloache).
restringida(amapola).
restringida(marihuana).

% ------------------------------------------------------------------------------
% 2. REGLAS DE TAXONOMIA
% ------------------------------------------------------------------------------
genero(Nombre, Genero) :-
    optima(Nombre, Especie, _, _, _),
    atomic_list_concat([Genero|_], '_', Especie).

jerarquia(Nombre, Familia, Genero) :-
    familia(Nombre, Familia),
    genero(Nombre, Genero).

parientes(A, B) :-
    familia(A, F), familia(B, F), A \= B.

mismo_genero(A, B) :-
    genero(A, G), genero(B, G), A \= B.

% ------------------------------------------------------------------------------
% 3. MOTOR DE RECOMENDACION
% ------------------------------------------------------------------------------
espacio_adecuado(balcon,       mucha_luz).
espacio_adecuado(terraza,      mucha_luz).
espacio_adecuado(jardin,       mucha_luz).
espacio_adecuado(departamento, poca_luz).
espacio_adecuado(oficina,      poca_luz).

cabe_en(jardin,       grande).
cabe_en(jardin,       mediano).
cabe_en(jardin,       pequeno).
cabe_en(terraza,      mediano).
cabe_en(terraza,      pequeno).
cabe_en(balcon,       mediano).
cabe_en(balcon,       pequeno).
cabe_en(departamento, pequeno).
cabe_en(oficina,      pequeno).

% Escalas ordinales (permiten medir "que tan cerca" esta un valor de otro)
nivel(poca, 1).          nivel(moderada, 2).       nivel(muy_alta, 3).
nivel(tiene_pocas, 1).   nivel(tiene_moderada, 2). nivel(tiene_muchas, 3).

distancia(X, Y, D) :- nivel(X, NX), nivel(Y, NY), D is abs(NX - NY).

pts_humedad(0, 30) :- !.
pts_humedad(1, 15) :- !.
pts_humedad(_, 0).

pts_follaje(0, 20) :- !.
pts_follaje(1, 10) :- !.
pts_follaje(_, 0).

% desglose(+Espacio, +Humedad, +Follaje, ?Nombre, ?Especie, -PLuz, -PHum, -PFol, -PTam)
desglose(Espacio, Humedad, Follaje, Nombre, Especie, PLuz, PHum, PFol, PTam) :-
    espacio_adecuado(Espacio, LuzEspacio),
    optima(Nombre, Especie, Luz, H, F),
    ( Luz == LuzEspacio -> PLuz = 40 ; PLuz = 0 ),
    distancia(H, Humedad, DH), pts_humedad(DH, PHum),
    distancia(F, Follaje, DF), pts_follaje(DF, PFol),
    tamano(Nombre, T),
    ( cabe_en(Espacio, T) -> PTam = 10 ; PTam = 0 ).

puntaje(Espacio, Humedad, Follaje, Nombre, Especie, P) :-
    desglose(Espacio, Humedad, Follaje, Nombre, Especie, A, B, C, D),
    P is A + B + C + D.

% Reglas especiales
apta_hogar(Nombre) :-
    optima(Nombre, _, _, _, _),
    \+ toxica(Nombre),
    \+ restringida(Nombre).

bajo_mantenimiento(Nombre, Especie) :-
    optima(Nombre, Especie, _, Humedad, _),
    nivel(Humedad, N), N =< 2,
    tamano(Nombre, T), T \== grande.

planta_cultivable(Nombre, Especie) :-
    optima(Nombre, Especie, _, _, _),
    uso(Nombre, comestible),
    apta_hogar(Nombre).

uso_ok(cualquiera, _) :- !.
uso_ok(Uso, Nombre) :- uso(Nombre, Uso).

seguridad_ok(no, _) :- !.
seguridad_ok(si, Nombre) :- apta_hogar(Nombre).

% ranking(+Espacio, +Humedad, +Follaje, +Uso, +SoloSeguras, -Nombre, -Especie, -Puntaje)
% Devuelve las soluciones ordenadas de mayor a menor puntaje.
ranking(Espacio, Humedad, Follaje, Uso, Seguras, Nombre, Especie, Puntaje) :-
    findall(NP-(N-E),
            ( puntaje(Espacio, Humedad, Follaje, N, E, P0),
              uso_ok(Uso, N),
              seguridad_ok(Seguras, N),
              NP is -P0 ),
            Lista),
    keysort(Lista, Ordenada),
    member(NP-(Nombre-Especie), Ordenada),
    Puntaje is -NP.

% Version estricta (todos los criterios deben coincidir exactamente)
recomendar_avanzado(Espacio, Humedad, Follaje, Nombre, Especie) :-
    espacio_adecuado(Espacio, Luz),
    optima(Nombre, Especie, Luz, Humedad, Follaje).

% ------------------------------------------------------------------------------
% 5. ASOCIACIONES ENTRE PLANTAS (conocimiento ilustrativo de jardineria)
% ------------------------------------------------------------------------------
beneficia(neem, mandarino).       % control natural de plagas en citricos
beneficia(neem, albahaca).
beneficia(margarita, mandarino).  % atrae polinizadores
beneficia(margarita, alcachofera).
beneficia(albahaca, mandarino).
beneficia(epazote, chayote).      % repele plagas de cucurbitaceas
beneficia(epazote, albahaca).
beneficia(albahaca, alcachofera).
beneficia(hierbabuena, mandarino).
beneficia(papiro, hierbabuena).   % ambos toleran humedad muy alta
beneficia(chayote, papiro).

perjudica(hierbabuena, remolacha).   % invasiva, compite por espacio
perjudica(hierbabuena, margarita).
perjudica(pino, remolacha).          % acidifica el suelo
perjudica(cipres, margarita).        % sombra y acidez
perjudica(toloache, albahaca).       % competencia y toxicidad

motivo(neem, mandarino, 'Repele plagas de citricos').
motivo(neem, albahaca, 'Protege contra insectos chupadores').
motivo(margarita, mandarino, 'Atrae polinizadores').
motivo(margarita, alcachofera, 'Atrae polinizadores').
motivo(albahaca, mandarino, 'Aroma que confunde plagas').
motivo(epazote, chayote, 'Repele plagas de cucurbitaceas').
motivo(epazote, albahaca, 'Aromaticas que se refuerzan').
motivo(albahaca, alcachofera, 'Aroma que confunde plagas').
motivo(hierbabuena, mandarino, 'Aroma que aleja hormigas').
motivo(papiro, hierbabuena, 'Comparten necesidad de humedad muy alta').
motivo(chayote, papiro, 'Comparten necesidad de humedad muy alta').
motivo(hierbabuena, remolacha, 'Invasiva: compite por espacio').
motivo(hierbabuena, margarita, 'Invasiva: compite por espacio').
motivo(pino, remolacha, 'Acidifica el suelo').
motivo(cipres, margarita, 'Sombra y acidez del suelo').
motivo(toloache, albahaca, 'Competencia y toxicidad').

incompatible(A, B) :- perjudica(A, B) ; perjudica(B, A).

compatible(A, B) :-
    ( beneficia(A, B) ; beneficia(B, A) ),
    \+ incompatible(A, B).

% camino(+A, +B, -Camino): cadena de plantas compatibles que conecta A con B
% (busqueda en profundidad con lista de visitados para evitar ciclos).
camino(A, B, Camino) :-
    A \== B,
    camino_(A, B, [A], R),
    reverse(R, Camino).

camino_(A, B, Visitados, [B|Visitados]) :- compatible(A, B).
camino_(A, B, Visitados, Camino) :-
    compatible(A, C),
    \+ memberchk(C, Visitados),
    camino_(C, B, [C|Visitados], Camino).

% ------------------------------------------------------------------------------
% 6. DIAGNOSTICO FITOSANITARIO MULTI-SINTOMA
% ------------------------------------------------------------------------------
sintoma(clorosis_hojas_viejas,  'Clorosis en hojas viejas').
sintoma(bordes_secos,           'Bordes de hojas secos').
sintoma(pudricion_tallos,       'Pudricion blanda en tallos').
sintoma(hojas_amarillentas,     'Hojas amarillentas').
sintoma(puntos_algodonosos,     'Puntos blancos algodonosos en el enves').
sintoma(melaza_pegajosa,        'Residuo pegajoso en hojas').
sintoma(crecimiento_raquitico,  'Crecimiento raquitico').
sintoma(sin_brotes,             'Falta de brotes nuevos').
sintoma(hojas_enrolladas,       'Hojas enrolladas').
sintoma(telaranas,              'Hilos de telarana en la planta').
sintoma(sustrato_encharcado,    'Sustrato encharcado').
sintoma(sustrato_seco,          'Sustrato seco y compactado').

% causa(Id, Problema, Tratamiento, Gravedad)
causa(sub_riego,   'Estres hidrico por sub-riego',
      'Aumentar la frecuencia de riego y evaluar la permeabilidad del sustrato.', media).
causa(exceso_agua, 'Exceso de humedad / asfixia radicular',
      'Suspender el riego, mejorar el drenaje y aplicar fungicida.', alta).
causa(cochinilla,  'Infestacion por cochinilla algodonosa',
      'Limpieza manual con alcohol y solucion de jabon potasico.', media).
causa(nitrogeno,   'Deficiencia de nutrientes (nitrogeno)',
      'Fertilizar con humus de lombriz o composta balanceada.', baja).
causa(arana_roja,  'Plaga de arana roja (Tetranychidae)',
      'Aumentar la humedad ambiental y aplicar acaricida especifico.', alta).

sintoma_de(sub_riego,   clorosis_hojas_viejas).
sintoma_de(sub_riego,   bordes_secos).
sintoma_de(sub_riego,   sustrato_seco).
sintoma_de(exceso_agua, pudricion_tallos).
sintoma_de(exceso_agua, hojas_amarillentas).
sintoma_de(exceso_agua, sustrato_encharcado).
sintoma_de(cochinilla,  puntos_algodonosos).
sintoma_de(cochinilla,  melaza_pegajosa).
sintoma_de(cochinilla,  hojas_amarillentas).
sintoma_de(nitrogeno,   crecimiento_raquitico).
sintoma_de(nitrogeno,   sin_brotes).
sintoma_de(nitrogeno,   clorosis_hojas_viejas).
sintoma_de(arana_roja,  hojas_enrolladas).
sintoma_de(arana_roja,  telaranas).
sintoma_de(arana_roja,  bordes_secos).

% confianza = interseccion(observados, sintomas de la causa) / union(observados, sintomas de la causa)
% (indice de Jaccard expresado en porcentaje)
confianza(Observados, Causa, Porcentaje) :-
    causa(Causa, _, _, _),
    findall(S, sintoma_de(Causa, S), Propios),
    intersection(Propios, Observados, Comunes), Comunes \== [],
    union(Propios, Observados, Union),
    length(Comunes, K), length(Union, U),
    Porcentaje is round(100 * K / U).

% diagnosticar(+Observados, -Causa, -Problema, -Tratamiento, -Gravedad, -Confianza)
diagnosticar(Observados, Causa, Problema, Tratamiento, Gravedad, Confianza) :-
    findall(NC-Id, ( confianza(Observados, Id, C), NC is -C ), Pares),
    keysort(Pares, Ordenados),
    member(NC-Causa, Ordenados),
    causa(Causa, Problema, Tratamiento, Gravedad),
    Confianza is -NC.