import { AbsoluteFill, Img, Sequence, continueRender, delayRender, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig, Easing } from 'remotion';
import { useEffect, useState } from 'react';

// Colores de la app (DESIGN.md, modo oscuro).
const C = { lienzo: '#0f172b', superficie: '#1d293d', azul: '#1d2b4a', azulVivo: '#1d447c', sol: '#e8ab3e', tinta: '#f1f5f9', tintaSuave: '#a7b4c8' };
const FUENTE = 'Onest, sans-serif';

// Cada escena: desde (frame), cuánto dura, y qué muestra.
const ESCENAS = [
  { tipo: 'entrada', dura: 120 },
  { tipo: 'pantalla', dura: 180, img: '01-inicio.png', etiqueta: 'Inicio', titulo: 'Todo lo de hoy, al abrir', texto: 'Tus jóvenes, quién está en enfermería y el conteo de la noche.' },
  { tipo: 'pantalla', dura: 180, img: '02-compania.png', etiqueta: 'Mi compañía', titulo: 'Tu compañía, a mano', texto: 'Tus jóvenes, sus cuartos y su comedor, siempre al día.' },
  { tipo: 'pantalla', dura: 180, img: '03-agenda.png', etiqueta: 'Agenda', titulo: 'La semana, hora por hora', texto: 'Toca una actividad: dónde es, a qué hora y lo que te toca.' },
  { tipo: 'pantalla', dura: 180, img: '04-enfermeria.png', etiqueta: 'Enfermería', titulo: '¿Un joven se siente mal?', texto: 'Avisa que lo llevas y sigue cómo está, en vivo.', toque: { x: 0.26, y: 0.165 } },
  { tipo: 'pantalla', dura: 180, img: '05-conteo.png', etiqueta: 'Conteo', titulo: 'Pasa lista en la noche', texto: 'Un toque por joven, y la dirección lo ve al instante.' },
  { tipo: 'dos', dura: 180, imgs: ['07-alertas.png', '06-mi-qr.png'], etiqueta: 'Alertas y Mi QR', titulo: 'Te enteras de todo', texto: 'Los avisos llegan a tu teléfono, y tu código QR abre tu ficha.' },
  { tipo: 'salida', dura: 180 },
];
// Cada escena empieza CRUCE frames antes de que termine la anterior: se funden sin un instante vacío.
const CRUCE = 12;
export const DURACION = ESCENAS.reduce((total, escena) => total + escena.dura, 0) - CRUCE * (ESCENAS.length - 1);

const useFuente = () => {
  const [handle] = useState(() => delayRender('Fuente Onest'));
  useEffect(() => {
    const fuente = new FontFace('Onest', `url(${staticFile('onest-latin.woff2')}) format('woff2')`, { weight: '100 900' });
    fuente.load().then((cargada) => { document.fonts.add(cargada); continueRender(handle); }).catch(() => continueRender(handle));
  }, [handle]);
};

// Entra y sale con un fundido corto; el contenido sube un poco al entrar.
const useEntrada = (dura) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const subida = spring({ frame, fps, config: { damping: 200 }, durationInFrames: 24 });
  const opacidad = interpolate(frame, [0, CRUCE, dura - CRUCE, dura], [0, 1, 1, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' });
  return { frame, fps, subida, opacidad };
};

const Fondo = () => {
  const frame = useCurrentFrame();
  const brillo = interpolate(frame, [0, DURACION], [0.18, 0.3]);
  return (
    <AbsoluteFill style={{ background: `radial-gradient(120% 70% at 50% 0%, ${C.azulVivo} 0%, ${C.azul} 38%, ${C.lienzo} 78%)` }}>
      <div style={{ position: 'absolute', left: '50%', top: -380, width: 1100, height: 1100, marginLeft: -550, borderRadius: '50%',
                    background: `radial-gradient(circle, rgba(232,171,62,${brillo}) 0%, transparent 62%)` }} />
    </AbsoluteFill>
  );
};

const Texto = ({ etiqueta, titulo, texto, subida, opacidad }) => (
  <div style={{ position: 'absolute', top: 120, left: 80, right: 80, textAlign: 'center', opacity: opacidad,
                transform: `translateY(${(1 - subida) * 40}px)`, fontFamily: FUENTE }}>
    <div style={{ color: C.sol, fontSize: 34, fontWeight: 800, letterSpacing: '0.12em', textTransform: 'uppercase' }}>{etiqueta}</div>
    <div style={{ color: C.tinta, fontSize: 76, fontWeight: 800, lineHeight: 1.08, marginTop: 18, letterSpacing: '-0.01em', textWrap: 'balance' }}>{titulo}</div>
    <div style={{ color: C.tintaSuave, fontSize: 38, fontWeight: 500, lineHeight: 1.35, marginTop: 22, textWrap: 'balance' }}>{texto}</div>
  </div>
);

// Un teléfono con la captura adentro, que se acerca despacio mientras dura la escena.
const Telefono = ({ img, ancho = 620, frame, dura, toque, estilo }) => {
  const alto = ancho * (2517 / 1236);
  const acerca = interpolate(frame, [0, dura], [1, 1.035]);
  const aro = toque ? (frame % 45) / 45 : 0;
  return (
    <div style={{ width: ancho + 28, height: alto + 28, padding: 14, borderRadius: 86, background: '#05070d',
                  boxShadow: '0 40px 120px rgba(0,0,0,0.55), 0 0 0 2px rgba(255,255,255,0.08)', ...estilo }}>
      <div style={{ position: 'relative', width: ancho, height: alto, borderRadius: 72, overflow: 'hidden', background: C.lienzo }}>
        <Img src={staticFile(img)} style={{ width: ancho, display: 'block', transform: `scale(${acerca})`, transformOrigin: '50% 20%' }} />
        {toque && frame > 40 && (
          <div style={{ position: 'absolute', left: toque.x * ancho - 50, top: toque.y * alto - 50, width: 100, height: 100, borderRadius: '50%',
                        border: `6px solid ${C.sol}`, opacity: 1 - aro, transform: `scale(${0.5 + aro})` }} />
        )}
      </div>
    </div>
  );
};

const Pantalla = ({ escena }) => {
  const { frame, subida, opacidad } = useEntrada(escena.dura);
  return (
    <AbsoluteFill style={{ opacity: opacidad }}>
      <Texto {...escena} subida={subida} opacidad={1} />
      <div style={{ position: 'absolute', left: '50%', top: 560, transform: `translateX(-50%) translateY(${(1 - subida) * 160}px) scale(${0.94 + subida * 0.06})` }}>
        <Telefono img={escena.img} frame={frame} dura={escena.dura} toque={escena.toque} />
      </div>
    </AbsoluteFill>
  );
};

const Dos = ({ escena }) => {
  const { frame, fps, subida, opacidad } = useEntrada(escena.dura);
  const segundo = spring({ frame: frame - 12, fps, config: { damping: 200 }, durationInFrames: 24 });
  return (
    <AbsoluteFill style={{ opacity: opacidad }}>
      <Texto {...escena} subida={subida} opacidad={1} />
      <div style={{ position: 'absolute', top: 600, left: 0, right: 0, display: 'flex', justifyContent: 'center', gap: 36 }}>
        <div style={{ transform: `translateY(${(1 - subida) * 160}px) rotate(-3deg)` }}><Telefono img={escena.imgs[0]} ancho={450} frame={frame} dura={escena.dura} /></div>
        <div style={{ transform: `translateY(${80 + (1 - segundo) * 200}px) rotate(3deg)` }}><Telefono img={escena.imgs[1]} ancho={450} frame={frame} dura={escena.dura} /></div>
      </div>
    </AbsoluteFill>
  );
};

const Marca = ({ subida, tamano = 260 }) => (
  <Img src={staticFile('icon-512.png')} style={{ width: tamano, height: tamano, borderRadius: tamano * 0.22,
       boxShadow: '0 30px 90px rgba(0,0,0,0.5)', transform: `scale(${0.6 + subida * 0.4})` }} />
);

const Entrada = ({ escena }) => {
  const { frame, fps, subida, opacidad } = useEntrada(escena.dura);
  const texto = spring({ frame: frame - 14, fps, config: { damping: 200 }, durationInFrames: 26 });
  return (
    <AbsoluteFill style={{ opacity: opacidad, alignItems: 'center', justifyContent: 'center', fontFamily: FUENTE, textAlign: 'center' }}>
      <Marca subida={subida} />
      <div style={{ opacity: texto, transform: `translateY(${(1 - texto) * 30}px)`, marginTop: 70 }}>
        <div style={{ color: C.sol, fontSize: 38, fontWeight: 800, letterSpacing: '0.14em' }}>FSY 2026 · MANAGUA-CARIBE</div>
        <div style={{ color: C.tinta, fontSize: 96, fontWeight: 800, lineHeight: 1.05, marginTop: 26 }}>La app del staff</div>
        <div style={{ color: C.tintaSuave, fontSize: 42, fontWeight: 500, marginTop: 26 }}>Todo lo de la semana, en tu teléfono</div>
      </div>
    </AbsoluteFill>
  );
};

const Paso = ({ numero, children, aparece }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 28, opacity: aparece, transform: `translateX(${(1 - aparece) * 40}px)`,
                background: 'rgba(255,255,255,0.06)', border: '2px solid rgba(255,255,255,0.08)', borderRadius: 36, padding: '30px 36px' }}>
    <div style={{ width: 76, height: 76, borderRadius: 24, background: C.sol, color: C.azul, fontSize: 42, fontWeight: 800,
                  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{numero}</div>
    <div style={{ color: C.tinta, fontSize: 40, fontWeight: 600, lineHeight: 1.3, textAlign: 'left' }}>{children}</div>
  </div>
);

const Salida = ({ escena }) => {
  const { frame, fps, subida, opacidad } = useEntrada(escena.dura + 60);
  const paso = (n) => spring({ frame: frame - 18 - n * 14, fps, config: { damping: 200 }, durationInFrames: 22 });
  const final = interpolate(frame, [escena.dura - 12, escena.dura], [1, 1], { extrapolateRight: 'clamp' });
  return (
    <AbsoluteFill style={{ opacity: Math.min(opacidad, final), alignItems: 'center', justifyContent: 'center', fontFamily: FUENTE, padding: 90 }}>
      <Marca subida={subida} tamano={200} />
      <div style={{ color: C.tinta, fontSize: 84, fontWeight: 800, lineHeight: 1.08, marginTop: 60, textAlign: 'center' }}>Instálala en tu teléfono</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 26, marginTop: 60, width: '100%' }}>
        <Paso numero="1" aparece={paso(0)}>Abre el enlace que te llegó al correo y elige tu contraseña</Paso>
        <Paso numero="2" aparece={paso(1)}>Configuración → <b style={{ color: C.sol }}>Instalar la app</b></Paso>
        <Paso numero="3" aparece={paso(2)}>La primera vez, un tutorial de 5 minutos te guía</Paso>
      </div>
    </AbsoluteFill>
  );
};

export const Presentacion = () => {
  useFuente();
  let desde = 0;
  return (
    <AbsoluteFill style={{ backgroundColor: C.lienzo }}>
      <Fondo />
      {ESCENAS.map((escena, i) => {
        const inicio = desde;
        desde += escena.dura - CRUCE;
        const Vista = { entrada: Entrada, pantalla: Pantalla, dos: Dos, salida: Salida }[escena.tipo];
        return (
          <Sequence key={i} from={inicio} durationInFrames={escena.dura}>
            <Vista escena={escena} />
          </Sequence>
        );
      })}
    </AbsoluteFill>
  );
};
