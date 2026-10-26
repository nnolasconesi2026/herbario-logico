"""
Herbario Lógico — Sistema experto botánico (Prolog + Streamlit)
Autora: Neshmi Natalia Nolasco Quezada | ESCOM IPN | Paradigmas de Programación
"""
import queue
import re
import threading
from pathlib import Path

import pandas as pd
import streamlit as st

PL_FILE = Path(__file__).parent / "plantas.pl"

st.set_page_config(page_title="Herbario Lógico | ESCOM IPN", page_icon="🌿", layout="wide")

def _py(v):
    if isinstance(v, bytes):
        return v.decode("utf-8", "replace")
    if isinstance(v, (str, int, float)):
        return v
    if isinstance(v, (list, tuple)):
        return [_py(x) for x in v]
    return str(v)

class PrologEngine:
    def __init__(self, path: str):
        self._jobs = queue.Queue()
        self._ready = threading.Event()
        self.error = None
        threading.Thread(target=self._run, args=(path,), daemon=True).start()
        self._ready.wait(timeout=30)

    def _run(self, path):
        try:
            from pyswip import Prolog
            prolog = Prolog()
            prolog.consult(Path(path).as_posix())
        except Exception as exc:
            self.error = exc
            self._ready.set()
            return
        self._ready.set()
        while True:
            goal, limit, box, done = self._jobs.get()
            try:
                box["rows"] = [{k: _py(v) for k, v in sol.items()}
                               for sol in prolog.query(goal, maxresult=limit)]
            except Exception as exc:
                box["error"] = exc
            done.set()

    def query(self, goal: str, limit: int = -1):
        box, done = {}, threading.Event()
        self._jobs.put((goal, limit, box, done))
        done.wait()
        if "error" in box:
            raise box["error"]
        return box["rows"]

@st.cache_resource(show_spinner="Iniciando motor SWI-Prolog…")
def get_engine():
    return PrologEngine(str(PL_FILE))

engine = get_engine()
if engine.error:
    st.error(f"No se pudo iniciar SWI-Prolog: {engine.error}")
    st.stop()

def ask(goal: str, limit: int = -1):
    return engine.query(goal.strip().rstrip("."), limit)

HUM = {"poca": "Poca", "moderada": "Moderada", "muy_alta": "Muy alta"}
FOL = {"tiene_pocas": "Escaso", "tiene_moderada": "Medio", "tiene_muchas": "Abundante"}
ESP = {"balcon": "Balcón", "terraza": "Terraza", "jardin": "Jardín",
       "departamento": "Departamento", "oficina": "Oficina"}
USO = {"cualquiera": "Cualquiera", "comestible": "Comestible", "medicinal": "Medicinal",
       "ornamental": "Ornamental", "aromatica": "Aromática", "industrial": "Industrial"}
LUZ = {"mucha_luz": "Mucha luz", "poca_luz": "Poca luz"}

def pretty(x):
    return str(x).replace("_", " ").capitalize()

def render_html_table(df):
    if df.empty:
        return "<p>No hay registros disponibles.</p>"
    html = '<table style="width:100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; border: 1px solid #d8e2dc; margin-top: 10px;">'
    html += '<thead><tr style="background-color: #0f3b32; color: white;">'
    for col in df.columns:
        html += f'<th style="padding: 12px 16px; text-align: left; font-weight: 600;">{str(col).capitalize()}</th>'
    html += '</tr></thead><tbody>'
    for _, row in df.iterrows():
        html += '<tr style="border-bottom: 1px solid #eef3ef;">'
        for val in row:
            html += f'<td style="padding: 12px 16px; color: #16211d;">{str(val)}</td>'
        html += '</tr>'
    html += '</tbody></table>'
    return html

@st.cache_data(show_spinner=False)
def load_catalog():
    rows = ask("optima(N,E,L,H,F)")
    fam = {r["N"]: r["F"] for r in ask("familia(N,F)")}
    tip = {r["N"]: r["T"] for r in ask("tipo(N,T)")}
    tam = {r["N"]: r["T"] for r in ask("tamano(N,T)")}
    gen = {r["N"]: r["G"] for r in ask("genero(N,G)")}
    usos = {}
    for r in ask("uso(N,U)"):
        usos.setdefault(r["N"], []).append(r["U"])
    tox = {r["N"] for r in ask("toxica(N)")}
    res = {r["N"] for r in ask("restringida(N)")}
    data = []
    for r in rows:
        n = r["N"]
        data.append({"nombre": n, "especie": r["E"], "luz": r["L"], "humedad": r["H"],
                     "follaje": r["F"], "familia": fam.get(n, ""), "tipo": tip.get(n, ""),
                     "tamano": tam.get(n, ""), "genero": gen.get(n, ""),
                     "usos": usos.get(n, []), "toxica": n in tox, "restringida": n in res})
    return pd.DataFrame(data)

@st.cache_data(show_spinner=False)
def load_stats():
    def count(goal):
        return ask(f"aggregate_all(count, {goal}, N)")[0]["N"]
    return {"especies": count("optima(_,_,_,_,_)"),
            "familias": len({r["F"] for r in ask("familia(_,F)")}),
            "asociaciones": count("beneficia(_,_)") + count("perjudica(_,_)"),
            "sintomas": count("sintoma(_,_)")}

catalog = load_catalog()
stats = load_stats()
info = catalog.set_index("nombre").to_dict("index")

st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,500;12..96,700&family=DM+Sans:wght@400;500;600&display=swap');
:root{--pine:#0f3b32;--fern:#2f7d57;--sprout:#b7e07a;--mist:#eef3ef;--ink:#16211d;
      --muted:#5b6b64;--line:#d8e2dc;--rust:#b4441c;--amber:#b7791f}
html, body, .stApp{font-family:'DM Sans',sans-serif;color:var(--ink)}
.stApp{background:#f4f7f5}
h1,h2,h3,h4{font-family:'Bricolage Grotesque',sans-serif !important;letter-spacing:-.01em}
.block-container{padding-top:2rem;max-width:1180px}
header[data-testid="stHeader"]{background:transparent}

.hero{position:relative;overflow:hidden;background:var(--pine);color:#eaf4ee;border-radius:22px;
      padding:34px 38px;margin-bottom:26px}
.hero h1{color:#fff;font-size:2.5rem;margin:6px 0 8px 0;line-height:1.05}
.hero p{color:#b9d3c6;margin:0;max-width:560px;font-size:1.02rem;line-height:1.5}
.stats{display:flex;gap:12px;flex-wrap:wrap;margin-top:22px}
.stat{background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.14);
      padding:8px 14px;border-radius:12px;font-size:.88rem;color:#d4e6dc}
.stat b{font-family:'Bricolage Grotesque',sans-serif;font-size:1.15rem;color:var(--sprout);margin-right:6px}

.stTabs [data-baseweb="tab-list"]{gap:4px;border-bottom:1px solid var(--line)}
.stTabs [data-baseweb="tab"]{height:44px;padding:0 16px;border-radius:10px 10px 0 0;font-weight:600;color:var(--muted)}
.stTabs [aria-selected="true"]{color:var(--pine)}
.stTabs [data-baseweb="tab-highlight"]{background:var(--fern)}

.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:16px;margin-top:8px}
.plant{background:#fff;border:1px solid var(--line);border-radius:16px;padding:18px 18px 16px;
       display:grid;grid-template-columns:1fr 78px;gap:6px 14px}
.plant h4{margin:0;font-size:1.25rem;color:var(--pine)}
.plant .sp{font-style:italic;color:var(--muted);font-size:.9rem;margin-top:2px}
.ring{--p:0;--c:var(--fern);width:72px;height:72px;border-radius:50%;display:grid;place-items:center;
      background:conic-gradient(var(--c) calc(var(--p)*1%),#e1eae4 0)}
.ring span{width:56px;height:56px;border-radius:50%;background:#fff;display:grid;place-items:center;
           font-family:'Bricolage Grotesque',sans-serif;font-weight:700;font-size:1.15rem;color:var(--pine)}
.pills{grid-column:1 / -1;display:flex;flex-wrap:wrap;gap:6px;margin-top:6px}
.pill{background:var(--mist);color:var(--pine);border-radius:999px;padding:3px 10px;font-size:.78rem;font-weight:500}
.pill.warn{background:#fbe9e1;color:var(--rust)}
.pill.use{background:#e4f2d0;color:#3d5a14}
.bars{grid-column:1 / -1;display:grid;grid-template-columns:70px 1fr 34px;gap:5px 8px;
      align-items:center;font-size:.78rem;color:var(--muted);margin-top:8px}
.bar{height:6px;background:#e8efea;border-radius:4px;overflow:hidden}
.bar i{display:block;height:100%;background:var(--fern);border-radius:4px}

.verdict{border-radius:16px;padding:20px 22px;border:1px solid var(--line);background:#fff;margin:6px 0 14px}
.verdict h3{margin:0 0 6px 0}
.verdict.good{border-left:6px solid var(--fern)}
.verdict.bad{border-left:6px solid var(--rust)}
.verdict.neutral{border-left:6px solid var(--amber)}
.diag{background:#fff;border:1px solid var(--line);border-radius:16px;padding:18px 20px;margin-bottom:12px}
.diag h4{margin:0 0 4px 0;color:var(--pine)}
.diag .tx{color:var(--ink);margin:10px 0 0 0}
.foot{color:var(--muted);font-size:.85rem;text-align:center;margin-top:40px}
</style>
""", unsafe_allow_html=True)

st.markdown(f"""<div class="hero">
<h1>Herbario Lógico</h1>
<p>Sistema experto escrito en Prolog para recomendación, diagnóstico y relaciones botánicas.</p>
<div class="stats">
<div class="stat"><b>{stats['especies']}</b>especies</div>
<div class="stat"><b>{stats['familias']}</b>familias</div>
<div class="stat"><b>{stats['asociaciones']}</b>asociaciones</div>
<div class="stat"><b>{stats['sintomas']}</b>síntomas</div>
</div></div>""", unsafe_allow_html=True)

tabs = st.tabs(["Recomendador", "Diagnóstico", "Asociaciones", "Taxonomía",
                "Consola Prolog", "Base de conocimiento"])

with tabs[0]:
    st.markdown("### ¿Qué planta le queda a tu espacio?")
    c1, c2, c3, c4 = st.columns(4)
    espacio = c1.selectbox("Espacio", list(ESP), format_func=ESP.get)
    humedad = c2.selectbox("Humedad del ambiente", list(HUM), index=1, format_func=HUM.get)
    follaje = c3.selectbox("Follaje deseado", list(FOL), index=2, format_func=FOL.get)
    uso = c4.selectbox("Uso", list(USO), format_func=USO.get)
    f1, f2 = st.columns([1, 1])
    seguras = f1.toggle("Solo plantas seguras para el hogar", value=True)
    minimo = f2.slider("Puntaje mínimo", 0, 100, 60, step=5)

    goal = f"ranking({espacio}, {humedad}, {follaje}, {uso}, {'si' if seguras else 'no'}, Nombre, Especie, Puntaje)"
    rows = [r for r in ask(goal) if r["Puntaje"] >= minimo]
    parts = {r["N"]: (r["A"], r["B"], r["C"], r["D"]) for r in
             ask(f"desglose({espacio}, {humedad}, {follaje}, N, _, A, B, C, D)")}

    if not rows:
        st.info("Ninguna especie llega al puntaje mínimo con esas condiciones.")
    else:
        html = ['<div class="grid">']
        for r in rows:
            n, p = r["Nombre"], r["Puntaje"]
            d = info[n]
            color = "var(--fern)" if p >= 85 else "#8aa63a" if p >= 65 else "var(--amber)"
            pills = [f'<span class="pill">{pretty(d["tipo"])}</span>',
                     f'<span class="pill">{pretty(d["familia"])}</span>',
                     f'<span class="pill">Tamaño {d["tamano"]}</span>']
            pills += [f'<span class="pill use">{pretty(u)}</span>' for u in d["usos"]]
            if d["toxica"]: pills.append('<span class="pill warn">Tóxica</span>')
            if d["restringida"]: pills.append('<span class="pill warn">Regulada</span>')
            a, b, c, dd = parts.get(n, (0, 0, 0, 0))
            bars = "".join(f'<span>{lab}</span><div class="bar"><i style="width:{v * 100 // mx}%"></i></div><span>{v}</span>'
                           for lab, v, mx in [("Luz", a, 40), ("Humedad", b, 30), ("Follaje", c, 20), ("Tamaño", dd, 10)])
            html.append(f'<div class="plant"><div><h4>{pretty(n)}</h4><div class="sp">{pretty(r["Especie"])}</div></div>'
                        f'<div class="ring" style="--p:{p};--c:{color}"><span>{p}</span></div>'
                        f'<div class="pills">{"".join(pills)}</div><div class="bars">{bars}</div></div>')
        html.append("</div>")
        st.markdown("".join(html), unsafe_allow_html=True)

with tabs[1]:
    st.markdown("### Diagnóstico fitosanitario")
    sint = {r["I"]: r["T"] for r in ask("sintoma(I, T)")}
    obs = st.multiselect("Síntomas observados", list(sint), format_func=sint.get)
    if obs:
        lista = "[" + ",".join(obs) + "]"
        diags = ask(f"diagnosticar({lista}, C, P, T, G, Conf)")
        grav = {"alta": ("#b4441c", "Gravedad alta"), "media": ("#b7791f", "Gravedad media"), "baja": ("#2f7d57", "Gravedad baja")}
        for d in diags:
            col, label = grav[d["G"]]
            st.markdown(f'<div class="diag"><h4>{d["P"]}</h4><span class="pill" style="background:{col}1f;color:{col}">{label}</span>'
                        f'<p class="tx"><b>Tratamiento:</b> {d["T"]}</p></div>', unsafe_allow_html=True)

with tabs[2]:
    st.markdown("### Asociaciones")
    names = sorted(catalog["nombre"])
    a_col, b_col = st.columns(2)
    pa = a_col.selectbox("Planta A", names, index=0, format_func=pretty)
    pb = b_col.selectbox("Planta B", names, index=1, format_func=pretty)
    if pa != pb:
        motivo = ask(f"motivo({pa}, {pb}, M)") or ask(f"motivo({pb}, {pa}, M)")
        razon = motivo[0]["M"] if motivo else ""
        if ask(f"incompatible({pa}, {pb})", 1):
            st.markdown(f'<div class="verdict bad"><h3>No conviene plantarlas juntas</h3><p>{razon}</p></div>', unsafe_allow_html=True)
        elif ask(f"compatible({pa}, {pb})", 1):
            st.markdown(f'<div class="verdict good"><h3>Se benefician mutuamente</h3><p>{razon}</p></div>', unsafe_allow_html=True)
        else:
            st.markdown('<div class="verdict neutral"><h3>Sin relación directa</h3></div>', unsafe_allow_html=True)

with tabs[3]:
    st.markdown("### Taxonomía")
    fam_sel = st.multiselect("Filtrar por familia", sorted(catalog["familia"].unique()), format_func=pretty)
    sub = catalog[catalog["familia"].isin(fam_sel)] if fam_sel else catalog
    df_sub = pd.DataFrame({
        "Nombre": sub["nombre"].map(pretty),
        "Especie": sub["especie"].map(pretty),
        "Familia": sub["familia"].map(pretty),
        "Tipo": sub["tipo"].map(pretty)
    })
    st.markdown(render_html_table(df_sub), unsafe_allow_html=True)

with tabs[4]:
    st.markdown("### Consola Prolog")
    consulta = st.text_input("?-", value="optima(N, E, mucha_luz, poca, F)")
    if st.button("Ejecutar consulta"):
        try:
            res = ask(consulta.strip().rstrip("."), 50)
            if res:
                df_res = pd.DataFrame(res)
                st.markdown(render_html_table(df_res), unsafe_allow_html=True)
            else:
                st.warning("false.")
        except Exception as exc:
            st.error(f"Error: {exc}")

with tabs[5]:
    st.markdown("### Base de conocimiento")
    df_cat = pd.DataFrame({
        "Nombre": catalog["nombre"].map(pretty),
        "Especie": catalog["especie"].map(pretty),
        "Luz": catalog["luz"].map(LUZ.get),
        "Humedad": catalog["humedad"].map(HUM.get),
        "Follaje": catalog["follaje"].map(FOL.get),
        "Familia": catalog["familia"].map(pretty),
        "Tipo": catalog["tipo"].map(pretty),
        "Tamaño": catalog["tamano"].map(pretty)
    })
    st.markdown(render_html_table(df_cat), unsafe_allow_html=True)