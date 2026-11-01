import { Composition } from 'remotion';
import { Presentacion, DURACION } from './Presentacion.jsx';

export const Root = () => (
  <Composition id="Presentacion" component={Presentacion} durationInFrames={DURACION} fps={30} width={1080} height={1920} />
);
