<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>A.N.G.I.E. // KARDIA-HUD 3D | Cirugía & Anatomía Cardiológica</title>
<style>
:root {
  --bg-deep: #030712;
  --hud-panel: rgba(8, 18, 38, 0.85);
  --cyan: #00f3ff;
  --cyan-soft: rgba(0, 243, 255, 0.22);
  --rose: #ff8fb1;
  --amber: #ffb800;
  --crimson: #ff2a5f;
  --mint: #10b981;
  --text-main: #e2f1ff;
  --text-muted: #7da2c1;
}
* { box-sizing: border-box; user-select: none; -webkit-user-select: none; }
body, html {
  margin: 0; padding: 0; width: 100%; height: 100%;
  background: radial-gradient(circle at 50% 45%, #0b1d3a 0%, #050b18 55%, #02040a 100%);
  color: var(--text-main);
  font-family: "Segoe UI", system-ui, -apple-system, sans-serif;
  overflow: hidden;
}
/* Malla holográfica de fondo */
body::before {
  content: ""; position: fixed; inset: 0; pointer-events: none; z-index: 1;
  background-image: 
    linear-gradient(rgba(0, 243, 255, 0.04) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 243, 255, 0.04) 1px, transparent 1px);
  background-size: 40px 40px;
}

#canvas-container { position: fixed; inset: 0; z-index: 2; }
#annotation-canvas {
  position: fixed; inset: 0; z-index: 3;
  pointer-events: none; touch-action: none;
}
#annotation-canvas.drawing-active { pointer-events: auto; cursor: crosshair; }

/* BARRA SUPERIOR HUD */
.topbar {
  position: fixed; top: 12px; left: 16px; right: 16px; z-index: 10;
  display: flex; justify-content: space-between; align-items: center;
  padding: 10px 20px; border-radius: 14px;
  background: var(--hud-panel);
  border: 1px solid var(--cyan-soft);
  backdrop-filter: blur(12px);
  box-shadow: 0 0 25px rgba(0, 243, 255, 0.12);
}
.brand { display: flex; align-items: center; gap: 12px; }
.arc-reactor {
  width: 34px; height: 34px; border-radius: 50%;
  border: 2px solid var(--cyan);
  box-shadow: 0 0 14px var(--cyan), inset 0 0 10px var(--cyan);
  display: grid; place-items: center; font-size: 0.85rem; color: var(--cyan);
  animation: rotateSlow 10s linear infinite;
}
.brand-title { font-weight: 800; letter-spacing: 0.12em; font-size: 0.92rem; color: var(--cyan); }
.brand-sub { font-size: 0.74rem; color: var(--text-muted); }

.vitals { display: flex; gap: 16px; align-items: center; font-size: 0.78rem; }
.vital-box { display: flex; align-items: center; gap: 6px; padding: 5px 10px; border-radius: 8px; background: rgba(0,243,255,0.06); border: 1px solid rgba(0,243,255,0.18); }
.pulse-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--crimson); box-shadow: 0 0 8px var(--crimson); animation: beat 0.8s infinite; }

/* PANEL IZQUIERDO: CONTROLES DE CAPAS */
.left-hud {
  position: fixed; top: 76px; left: 16px; bottom: 16px; width: 290px; z-index: 10;
  display: flex; flex-direction: column; gap: 12px; pointer-events: none;
}
.hud-card {
  pointer-events: auto;
  background: var(--hud-panel);
  border: 1px solid var(--cyan-soft);
  border-radius: 16px; padding: 14px 16px;
  backdrop-filter: blur(12px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.45);
}
.hud-label {
  font-size: 0.7rem; letter-spacing: 0.16em; text-transform: uppercase;
  color: var(--cyan); margin-bottom: 10px; font-weight: 700;
  display: flex; justify-content: space-between; align-items: center;
}
.layer-list, .region-grid { display: grid; gap: 7px; }
.region-grid { grid-template-columns: 1fr 1fr; }
.hud-btn {
  width: 100%; text-align: left; padding: 9px 12px; border-radius: 10px;
  border: 1px solid rgba(0, 243, 255, 0.22);
  background: rgba(0, 243, 255, 0.06);
  color: var(--text-main); font-size: 0.81rem; font-weight: 600;
  cursor: pointer; transition: all 0.2s;
  display: flex; align-items: center; justify-content: space-between;
}
.hud-btn:hover { background: rgba(0, 243, 255, 0.16); border-color: var(--cyan); box-shadow: 0 0 12px rgba(0,243,255,0.2); }
.hud-btn.active { background: rgba(0, 243, 255, 0.22); border-color: var(--cyan); color: #fff; }
.hud-btn.cardio-btn.active { background: rgba(255, 42, 95, 0.25); border-color: var(--crimson); color: #ff8fb1; }
.hud-btn.draw-btn.active { background: rgba(16, 185, 129, 0.25); border-color: var(--mint); color: #a7f3d0; }
.status-pill { font-size: 0.68rem; padding: 2px 6px; border-radius: 6px; background: rgba(255,255,255,0.1); }

/* HERRAMIENTAS DE LÁPIZ ÓPTICO / STYLUS */
#stylus-toolbar { display: none; margin-top: 10px; padding-top: 10px; border-top: 1px solid rgba(0,243,255,0.18); }
#stylus-toolbar.visible { display: block; }
.color-row { display: flex; gap: 8px; margin-bottom: 8px; }
.color-swatch {
  width: 26px; height: 26px; border-radius: 50%; cursor: pointer;
  border: 2px solid transparent; transition: transform 0.15s;
}
.color-swatch.selected { border-color: #fff; transform: scale(1.15); }

/* PANEL DERECHO: EXPEDIENTE CLÍNICO + COPILOTO IA */
.right-hud {
  position: fixed; top: 76px; right: 16px; bottom: 16px; width: 380px; z-index: 10;
  display: flex; flex-direction: column; gap: 12px; pointer-events: none;
}
.tabs-header { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; margin-bottom: 10px; }
.tab-btn {
  padding: 9px; border-radius: 10px; border: 1px solid var(--cyan-soft);
  background: rgba(0,243,255,0.05); color: var(--text-muted);
  font-weight: 700; font-size: 0.8rem; cursor: pointer; text-align: center;
}
.tab-btn.active { background: rgba(0,243,255,0.2); color: var(--cyan); border-color: var(--cyan); }

.clinical-panel { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.scroll-area { flex: 1; overflow-y: auto; padding-right: 4px; user-select: text; -webkit-user-select: text; }
.scroll-area::-webkit-scrollbar { width: 5px; }
.scroll-area::-webkit-scrollbar-thumb { background: var(--cyan-soft); border-radius: 8px; }

.structure-title { font-size: 1.25rem; font-weight: 800; color: #fff; margin: 0; }
.structure-latin { font-size: 0.8rem; color: var(--cyan); font-style: italic; margin: 3px 0 10px; }
.info-block {
  background: rgba(255,255,255,0.03); border-left: 3px solid var(--cyan);
  padding: 10px 12px; border-radius: 0 10px 10px 0; margin-bottom: 10px;
  font-size: 0.84rem; line-height: 1.55;
}
.info-block.cardio { border-left-color: var(--crimson); background: rgba(255, 42, 95, 0.06); }
.info-block.surgery { border-left-color: var(--mint); background: rgba(16, 185, 129, 0.06); }
.info-block strong { display: block; font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 4px; color: var(--cyan); }
.info-block.cardio strong { color: var(--rose); }
.info-block.surgery strong { color: var(--mint); }

/* CHAT COPILOTO A.N.G.I.E. */
#ai-tab-content { display: none; flex-direction: column; height: 100%; overflow: hidden; }
.chat-messages { flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; padding-right: 4px; margin-bottom: 10px; }
.msg { padding: 10px 13px; border-radius: 12px; font-size: 0.83rem; line-height: 1.5; max-width: 94%; user-select: text; -webkit-user-select: text; }
.msg.ai { background: rgba(0, 243, 255, 0.1); border: 1px solid rgba(0, 243, 255, 0.28); align-self: flex-start; color: var(--text-main); }
.msg.user { background: rgba(255, 143, 177, 0.18); border: 1px solid rgba(255, 143, 177, 0.4); align-self: flex-end; color: #fff; }
.msg-sender { font-size: 0.68rem; font-weight: 800; letter-spacing: 0.1em; text-transform: uppercase; color: var(--cyan); margin-bottom: 4px; }
.quick-chips { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 8px; }
.chip {
  font-size: 0.71rem; padding: 5px 9px; border-radius: 20px;
  background: rgba(0,243,255,0.08); border: 1px solid rgba(0,243,255,0.25);
  color: var(--cyan); cursor: pointer;
}
.chip:hover { background: rgba(0,243,255,0.2); }
.chat-input-row { display: flex; gap: 6px; }
.chat-input-row input {
  flex: 1; padding: 10px 12px; border-radius: 10px;
  border: 1px solid var(--cyan-soft); background: rgba(3, 7, 18, 0.8);
  color: #fff; font-size: 0.83rem; outline: none;
}
.chat-input-row button {
  padding: 10px 14px; border-radius: 10px; border: 0;
  background: var(--cyan); color: #020813; font-weight: 800; cursor: pointer;
}

#hud-reticle {
  position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%);
  z-index: 8; pointer-events: none; text-align: center;
  background: rgba(5, 14, 30, 0.82); border: 1px solid var(--cyan-soft);
  padding: 8px 18px; border-radius: 30px; font-size: 0.79rem; color: var(--cyan);
  backdrop-filter: blur(8px);
}

/* MODAL BIENVENIDA */
#welcome-modal {
  position: fixed; inset: 0; z-index: 50;
  background: rgba(2, 6, 15, 0.88); backdrop-filter: blur(14px);
  display: flex; align-items: center; justify-content: center; padding: 20px;
}
.modal-box {
  max-width: 500px; width: 100%; background: rgba(10, 22, 46, 0.95);
  border: 1px solid var(--cyan); border-radius: 22px; padding: 28px;
  text-align: center; box-shadow: 0 0 60px rgba(0, 243, 255, 0.25);
}
.modal-btn {
  margin-top: 18px; padding: 12px 24px; border-radius: 12px; border: 0;
  background: linear-gradient(120deg, var(--cyan), var(--rose));
  color: #030914; font-weight: 800; font-size: 0.92rem; cursor: pointer;
  box-shadow: 0 0 20px rgba(0, 243, 255, 0.4);
}

@keyframes rotateSlow { 100% { transform: rotate(360deg); } }
@keyframes beat { 0%, 100% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.35); opacity: 0.6; } }

@media (max-width: 900px) {
  .left-hud { width: 220px; top: 68px; }
  .right-hud { width: 310px; top: 68px; }
  .vitals { display: none; }
}
@media (max-width: 680px) {
  .left-hud { top: auto; bottom: 12px; left: 12px; right: 12px; width: auto; height: auto; flex-direction: row; overflow-x: auto; }
  .right-hud { top: 66px; left: 12px; right: 12px; bottom: auto; width: auto; max-height: 44vh; }
  #hud-reticle { display: none; }
}
</style>
<script type="importmap">
{
  "imports": {
    "three": "https://unpkg.com/three@0.160.0/build/three.module.js",
    "three/addons/": "https://unpkg.com/three@0.160.0/examples/jsm/"
  }
}
</script>
</head>
<body>

<div id="welcome-modal">
  <div class="modal-box">
    <div style="font-size:2.2rem;margin-bottom:8px">🫀⚡</div>
    <div style="font-size:0.72rem;letter-spacing:0.2em;color:var(--cyan);text-transform:uppercase">Sistema A.N.G.I.E. // KARDIA-HUD 3D</div>
    <h1 style="margin:10px 0;font-size:1.6rem;color:#fff">Bienvenida, Dra. Angie 💜</h1>
    <p style="color:var(--text-muted);font-size:0.91rem;line-height:1.6">
      Plataforma interactiva de anatomía humana, sistema vascular y cirugía cardiológica avanzada. Diseñada con amor para acompañar tus sueños de salvar corazones.
    </p>
    <button class="modal-btn" id="start-hud-btn">INICIAR SISTEMA KARDIA</button>
  </div>
</div>

<header class="topbar">
  <div class="brand">
    <div class="arc-reactor">❖</div>
    <div>
      <div class="brand-title">A.N.G.I.E. // KARDIA-HUD</div>
      <div class="brand-sub">Especialidad: Cirugía Cardiovascular & Anatomía 3D</div>
    </div>
  </div>
  <div class="vitals">
    <div class="vital-box"><span class="pulse-dot"></span> <span id="fc-text">FC: 72 LPM · Ritmo Sinusal</span></div>
    <div class="vital-box"><span>Stylus / Pencil: ACTIVO</span></div>
  </div>
</header>

<div id="canvas-container"></div>
<canvas id="annotation-canvas"></canvas>
<div id="hud-reticle">🎯 Toca cualquier estructura anatómica o activa el Modo Quirófano Cardiológico</div>

<aside class="left-hud">
  <div class="hud-card">
    <div class="hud-label"><span>🔬 Capas del Sistema</span><span>3D</span></div>
    <div class="layer-list">
      <button class="hud-btn active" id="toggle-bones"><span>🦴 Sistema Óseo</span><span class="status-pill">ON</span></button>
      <button class="hud-btn active" id="toggle-vessels"><span>🩸 Vasos y Cayado Aórtico</span><span class="status-pill">ON</span></button>
      <button class="hud-btn cardio-btn" id="toggle-cardio"><span>🫀 Modo Quirófano Cardio</span><span class="status-pill">OFF</span></button>
      <button class="hud-btn" id="toggle-xray"><span>👁️ Visión Rayos X</span><span class="status-pill">OFF</span></button>
      <button class="hud-btn draw-btn" id="toggle-stylus"><span>✏️ Modo Pencil / Bisturí</span><span class="status-pill">OFF</span></button>
    </div>

    <div id="stylus-toolbar">
      <div style="font-size:0.73rem;color:var(--text-muted);margin-bottom:6px">Color de trazo quirúrgico:</div>
      <div class="color-row">
        <div class="color-swatch selected" data-color="#00f3ff" style="background:#00f3ff"></div>
        <div class="color-swatch" data-color="#ff2a5f" style="background:#ff2a5f"></div>
        <div class="color-swatch" data-color="#ffb800" style="background:#ffb800"></div>
        <div class="color-swatch" data-color="#10b981" style="background:#10b981"></div>
      </div>
      <button class="hud-btn" id="clear-canvas-btn" style="justify-content:center;font-size:0.75rem">🗑️ Limpiar trazos</button>
    </div>
  </div>

  <div class="hud-card">
    <div class="hud-label"><span>🎥 Enfoque Corporal</span><span>ZONA</span></div>
    <div class="region-grid">
      <button class="hud-btn" data-cam="full">🧍 Cuerpo Total</button>
      <button class="hud-btn" data-cam="heart">🫀 Corazón</button>
      <button class="hud-btn" data-cam="head">🧠 Cráneo</button>
      <button class="hud-btn" data-cam="arm">💪 Brazo</button>
      <button class="hud-btn" data-cam="pelvis">🦴 Pelvis</button>
      <button class="hud-btn" data-cam="leg">🦵 Fémur / Tibia</button>
    </div>
  </div>
</aside>

<aside class="right-hud">
  <div class="hud-card clinical-panel">
    <div class="tabs-header">
      <button class="tab-btn active" id="tab-btn-info">📋 Atlas & Cirugía</button>
      <button class="tab-btn" id="tab-btn-ai">🤖 A.N.G.I.E. Copiloto</button>
    </div>

    <div id="info-tab-content" class="scroll-area">
      <h2 class="structure-title" id="st-name">Sistema Cardiovascular & Esqueleto</h2>
      <div class="structure-latin" id="st-latin">Cor et Vas Sanguineum</div>

      <div class="info-block cardio">
        <strong>🫀 Enfoque en Cirugía Cardiológica</strong>
        <div id="st-cardio">Selecciona el "Modo Quirófano Cardio" o haz clic en el corazón 3D para estudiar anatomía coronaria, bypass aortocoronario y fisiología valvular.</div>
      </div>

      <div class="info-block">
        <strong>📘 Anatomía General (Moore / Netter)</strong>
        <div id="st-anatomy">Sistema de referencia clínica interactivo para estudiantes y profesionales de medicina.</div>
      </div>

      <div class="info-block surgery">
        <strong>🔪 Abordaje Quirúrgico</strong>
        <div id="st-surgery">Técnicas de osteosíntesis, toracotomía y derivación cardiopulmonar.</div>
      </div>
    </div>

    <div id="ai-tab-content">
      <div class="chat-messages" id="chat-box"></div>
      <div class="quick-chips">
        <span class="chip" data-q="Explícame la anatomía del corazón y coronarias">🫀 Anatomía Cardíaca</span>
        <span class="chip" data-q="¿Cómo se realiza un Bypass Aortocoronario (CABG)?">🔪 Cirugía Bypass</span>
        <span class="chip" data-q="Fisiología de la Aorta y Presión arterial">🩸 Presión y Aorta</span>
        <span class="chip" data-q="Manejo clínico en cardiología">💊 Fármacos Cardiacos</span>
      </div>
      <div class="chat-input-row">
        <input type="text" id="chat-input" placeholder="Pregúntale a A.N.G.I.E. sobre cardiología o cirugía...">
        <button id="chat-send-btn">Enviar</button>
      </div>
    </div>
  </div>
</aside>

<script type="module">
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

const ANATOMY_DB = {
  heart: {
    name: "Corazón & Grandes Vasos",
    latin: "Cor, Aorta, Truncus Pulmonaris et Arteriae Coronariae",
    cam: { pos: [0, 4.3, 4.4], target: [0, 4.0, 0] },
    cardio: "El órgano motor del sistema circulatorio. Consta de 4 cavidades. Las arterias coronarias derecha e izquierda (que nacen en los senos aórticos de Valsalva) irrigan el miocardio. Su correcto funcionamiento es la base de la vida.",
    anatomy: "Ubicado en el mediastino medio, envuelto en el pericardio fibroso y seroso. Conecta con el cayado aórtico, la vena cava superior e inferior y el tronco pulmonar.",
    surgery: "Cirugía de Revascularización Miocárdica (CABG) utilizando la arteria mamaria interna (IMA) o vena safena, y reemplazos valvulares aórticos con circulación extracorpórea (bomba de perfusión)."
  },
  cranium: {
    name: "Cráneo y Encéfalo",
    latin: "Cranium et Encephalon",
    cam: { pos: [0, 7.2, 4.2], target: [0, 6.8, 0] },
    cardio: "Irritado por el Polígono de Willis (ramas de las carótidas internas y vertebrales), garantizando el flujo sanguíneo cerebral constante.",
    anatomy: "Estructura ósea que protege el sistema nervioso central. Clave en el control neurovegetativo de la frecuencia cardíaca y la presión arterial.",
    surgery: "Craneotomía descompresiva y microcirugía vascular cerebral para aneurismas."
  },
  spine: {
    name: "Columna Vertebral",
    latin: "Columna Vertebralis",
    cam: { pos: [2.2, 4.2, 5.5], target: [0, 3.8, 0] },
    cardio: "Protege la médula espinal y los nervios simpáticos y parasimpáticos que modulan el ritmo cardíaco y la vasoconstricción.",
    anatomy: "Eje axial compuesto por 33 vértebras y discos intervertebrales.",
    surgery: "Artrodesis vertebral y fijación con tornillos pediculares."
  },
  femur: {
    name: "Fémur (Muslo)",
    latin: "Os Femoris",
    cam: { pos: [0, -0.4, 5.2], target: [0, -0.5, 0] },
    cardio: "Irrigado por la arteria femoral (continuación de la ilíaca externa), principal vía de acceso para cateterismos cardíacos y angiografías.",
    anatomy: "Hueso más largo del cuerpo; su canal medular soporta altas cargas mecánicas.",
    surgery: "Clavo endomedular fresado y artroplastia de cadera."
  }
};

const container = document.getElementById("canvas-container");
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(42, window.innerWidth / window.innerHeight, 0.1, 100);
camera.position.set(0, 2.2, 14.5);

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
container.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.06;
controls.target.set(0, 1.5, 0);

scene.add(new THREE.AmbientLight(0x0a2540, 2.2));
const dirLight1 = new THREE.DirectionalLight(0x00f3ff, 2.4);
dirLight1.position.set(6, 10, 8);
scene.add(dirLight1);

const anatomyRoot = new THREE.Group();
scene.add(anatomyRoot);
const bonesGroup = new THREE.Group();
const vesselsGroup = new THREE.Group();
anatomyRoot.add(bonesGroup, vesselsGroup);

const clickableMeshes = [];

function createBoneMaterial() {
  return new THREE.MeshPhysicalMaterial({ color: 0xbae6fd, emissive: 0x004466, emissiveIntensity: 0.5, roughness: 0.3, transparent: true, opacity: 0.9 });
}
function createVesselMaterial(isArtery = true) {
  return new THREE.MeshStandardMaterial({ color: isArtery ? 0xff2a5f : 0x00a8ff, emissive: isArtery ? 0xb91c1c : 0x0284c7, emissiveIntensity: 0.8, roughness: 0.3, transparent: true, opacity: 0.92 });
}

function registerPart(mesh, key) {
  mesh.userData.anatomyKey = key;
  clickableMeshes.push(mesh);
  return mesh;
}

// Estructuras 3D base
const skull = registerPart(new THREE.Mesh(new THREE.SphereGeometry(0.65, 20, 20), createBoneMaterial()), "cranium");
skull.position.set(0, 6.9, 0);
bonesGroup.add(skull);

for (let i = 0; i < 15; i++) {
  const v = registerPart(new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.18, 0.16, 12), createBoneMaterial()), "spine");
  v.position.set(0, 5.6 - i * 0.22, -0.12);
  bonesGroup.add(v);
}

// CORAZÓN Y GRANDES VASOS (Protagonistas en Cardiología)
const heartMesh = registerPart(new THREE.Mesh(new THREE.SphereGeometry(0.42, 24, 24), createVesselMaterial(true)), "heart");
heartMesh.scale.set(1, 1.25, 0.9);
heartMesh.position.set(0.15, 4.4, 0.2);
vesselsGroup.add(heartMesh);

const aortaCurve = new THREE.CatmullRomCurve3([
  new THREE.Vector3(0.15, 4.6, 0.2),
  new THREE.Vector3(0.0, 5.2, 0.1),
  new THREE.Vector3(-0.15, 4.8, -0.05),
  new THREE.Vector3(-0.05, 3.2, 0)
]);
const aortaMesh = registerPart(new THREE.Mesh(new THREE.TubeGeometry(aortaCurve, 24, 0.08, 12, false), createVesselMaterial(true)), "heart");
vesselsGroup.add(aortaMesh);

[-1, 1].forEach(side => {
  const f = registerPart(new THREE.Mesh(new THREE.CylinderGeometry(0.16, 0.13, 2.6, 14), createBoneMaterial()), "femur");
  f.position.set(side * 0.75, -0.2, 0);
  bonesGroup.add(f);
});

let desiredCamPos = null;
let desiredTarget = null;

function focusStructure(key) {
  const info = ANATOMY_DB[key];
  if (!info) return;
  document.getElementById("st-name").textContent = info.name;
  document.getElementById("st-latin").textContent = info.latin;
  document.getElementById("st-cardio").textContent = info.cardio;
  document.getElementById("st-anatomy").textContent = info.anatomy;
  document.getElementById("st-surgery").textContent = info.surgery;
  document.getElementById("hud-reticle").innerHTML = `🫀 Analizando: <strong>${info.name}</strong> · <em>${info.latin}</em>`;

  desiredCamPos = new THREE.Vector3(...info.cam.pos);
  desiredTarget = new THREE.Vector3(...info.cam.target);
}

const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();

renderer.domElement.addEventListener("pointerdown", (e) => {
  const rect = renderer.domElement.getBoundingClientRect();
  pointer.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
  pointer.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;
  raycaster.setFromCamera(pointer, camera);
  const hits = raycaster.intersectObjects(clickableMeshes, false);
  if (hits.length > 0) {
    focusStructure(hits[0].object.userData.anatomyKey);
  }
});

const CAM_PRESETS = {
  full: { pos: [0, 2.2, 14.5], target: [0, 1.5, 0] },
  heart: { pos: [0, 4.3, 4.4], target: [0, 4.0, 0] },
  head: { pos: [0, 7.0, 4.2], target: [0, 6.7, 0] },
  arm: { pos: [3.2, 3.2, 4.8], target: [1.8, 3.0, 0] },
  pelvis: { pos: [0, 1.7, 4.8], target: [0, 1.6, 0] },
  leg: { pos: [0, -1.8, 6.5], target: [0, -1.8, 0] }
};

document.querySelectorAll("[data-cam]").forEach(btn => {
  btn.addEventListener("click", () => {
    const p = CAM_PRESETS[btn.dataset.cam];
    if (p) { desiredCamPos = new THREE.Vector3(...p.pos); desiredTarget = new THREE.Vector3(...p.target); }
  });
});

document.getElementById("toggle-bones").addEventListener("click", (e) => {
  const active = e.currentTarget.classList.toggle("active");
  bonesGroup.visible = active;
  e.currentTarget.querySelector(".status-pill").textContent = active ? "ON" : "OFF";
});
document.getElementById("toggle-vessels").addEventListener("click", (e) => {
  const active = e.currentTarget.classList.toggle("active");
  vesselsGroup.visible = active;
  e.currentTarget.querySelector(".status-pill").textContent = active ? "ON" : "OFF";
});

let cardioMode = false;
document.getElementById("toggle-cardio").addEventListener("click", (e) => {
  cardioMode = e.currentTarget.classList.toggle("active");
  e.currentTarget.querySelector(".status-pill").textContent = cardioMode ? "ON" : "OFF";
  if (cardioMode) {
    focusStructure("heart");
    addAiMessage("🫀 **Modo Quirófano Cardiológico Activado**. La cámara enfoca el motor vascular y coronario. Este es el campo donde transformarás vidas, Dra. Angie.");
  }
});

let xray = false;
document.getElementById("toggle-xray").addEventListener("click", (e) => {
  xray = e.currentTarget.classList.toggle("active");
  e.currentTarget.querySelector(".status-pill").textContent = xray ? "ON" : "OFF";
  bonesGroup.traverse(o => { if (o.isMesh && o.material) o.material.opacity = xray ? 0.2 : 0.9; });
});

// Stylus / Bisturí
const drawCanvas = document.getElementById("annotation-canvas");
const ctx = drawCanvas.getContext("2d");
let isDrawing = false;
let strokeColor = "#00f3ff";
function resizeCanvas() { drawCanvas.width = window.innerWidth; drawCanvas.height = window.innerHeight; }
resizeCanvas();

document.getElementById("toggle-stylus").addEventListener("click", (e) => {
  const active = e.currentTarget.classList.toggle("active");
  drawCanvas.classList.toggle("drawing-active", active);
  document.getElementById("stylus-toolbar").classList.toggle("visible", active);
  controls.enabled = !active;
  e.currentTarget.querySelector(".status-pill").textContent = active ? "ON" : "OFF";
});
document.querySelectorAll(".color-swatch").forEach(s => {
  s.addEventListener("click", () => {
    document.querySelectorAll(".color-swatch").forEach(x => x.classList.remove("selected"));
    s.classList.add("selected");
    strokeColor = s.style.backgroundColor;
  });
});
document.getElementById("clear-canvas-btn").addEventListener("click", () => ctx.clearRect(0,0,drawCanvas.width,drawCanvas.height));

drawCanvas.addEventListener("pointerdown", e => { if (!drawCanvas.classList.contains("drawing-active")) return; isDrawing = true; ctx.beginPath(); ctx.moveTo(e.clientX, e.clientY); });
drawCanvas.addEventListener("pointermove", e => { if (!isDrawing) return; ctx.strokeStyle = strokeColor; ctx.lineWidth = 3; ctx.lineCap = "round"; ctx.lineTo(e.clientX, e.clientY); ctx.stroke(); });
window.addEventListener("pointerup", () => isDrawing = false);

// Chat A.N.G.I.E.
const chatBox = document.getElementById("chat-box");
function addAiMessage(text, sender = "A.N.G.I.E. CLÍNICA") {
  const div = document.createElement("div");
  div.className = sender === "TÚ" ? "msg user" : "msg ai";
  div.innerHTML = `<div class="msg-sender">${sender}</div><div>${text.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")}</div>`;
  chatBox.appendChild(div);
  chatBox.scrollTop = chatBox.scrollHeight;
}

function answerQuery(q) {
  const query = q.toLowerCase();
  if (query.includes("corazon") || query.includes("corazón") || query.includes("coronaria") || query.includes("anatomía")) {
    focusStructure("heart");
    addAiMessage("Analizando anatomía cardíaca y coronaria. Las arterias coronarias derecha e izquierda perfunden el miocardio en sístole y diástole. ¿Revisamos el protocolo de bypass?");
  } else if (query.includes("bypass") || query.includes("cabg") || query.includes("cirugía")) {
    focusStructure("heart");
    addAiMessage("🔪 **Bypass Aortocoronario (CABG):** Se utiliza la arteria mamaria interna (IMA) para realizar un puente vascular que salte la estenosis de la arteria coronaria afectada, restaurando el flujo al miocardio.");
  } else {
    focusStructure("heart");
    addAiMessage("Dra. Angie, estoy aquí para asistirte en cada latido de tu formación en cirugía cardiológica. Pregúntame sobre anatomía, derivaciones o farmacología cardiovascular.");
  }
}

document.getElementById("chat-send-btn").addEventListener("click", () => {
  const inp = document.getElementById("chat-input");
  if (!inp.value.trim()) return;
  addAiMessage(inp.value, "TÚ");
  const val = inp.value; inp.value = "";
  setTimeout(() => answerQuery(val), 350);
});
document.getElementById("chat-input").addEventListener("keydown", e => { if (e.key === "Enter") document.getElementById("chat-send-btn").click(); });
document.querySelectorAll(".chip").forEach(c => c.addEventListener("click", () => { addAiMessage(c.dataset.q, "TÚ"); setTimeout(() => answerQuery(c.dataset.q), 300); }));

document.getElementById("start-hud-btn").addEventListener("click", () => {
  document.getElementById("welcome-modal").style.display = "none";
  addAiMessage("¡Hola, Dra. Angie! Sistema A.N.G.I.E. // KARDIA-HUD en línea. Toca cualquier estructura o el corazón 3D para comenzar el repaso clínico.");
});

document.getElementById("tab-btn-info").addEventListener("click", (e) => {
  e.currentTarget.classList.add("active"); document.getElementById("tab-btn-ai").classList.remove("active");
  document.getElementById("info-tab-content").style.display = "block"; document.getElementById("ai-tab-content").style.display = "none";
});
document.getElementById("tab-btn-ai").addEventListener("click", (e) => {
  e.currentTarget.classList.add("active"); document.getElementById("tab-btn-info").classList.remove("active");
  document.getElementById("ai-tab-content").style.display = "flex"; document.getElementById("info-tab-content").style.display = "none";
});

const clock = new THREE.Clock();
function animate() {
  requestAnimationFrame(animate);
  const t = clock.getElapsedTime();

  // Latido cardíaco realista (72 LPM)
  const beat = 1 + Math.pow(Math.sin(t * 3.8), 6) * 0.15;
  heartMesh.scale.set(1 * beat, 1.25 * beat, 0.9 * beat);

  if (desiredCamPos && desiredTarget) {
    camera.position.lerp(desiredCamPos, 0.07);
    controls.target.lerp(desiredTarget, 0.08);
    if (camera.position.distanceTo(desiredCamPos) < 0.08) { desiredCamPos = null; desiredTarget = null; }
  }

  controls.update();
  renderer.render(scene, camera);
}
animate();

window.addEventListener("resize", () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
  resizeCanvas();
});
</script>
</body>
</html>
