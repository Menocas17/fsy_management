# Video para consejeros y staff

Presentación de ~43 s (1080×1920, vertical) de la app, hecha con [Remotion](https://www.remotion.dev).
No forma parte de la app: es material para presentarla.

```bash
mkdir /tmp/video && cd /tmp/video
npm init -y && npm i remotion@4.0.534 @remotion/cli@4.0.534 react react-dom
cp -r <repo>/script/video src
npx remotion render src/index.jsx Presentacion fsy-app-staff.mp4
```

Las capturas que usa se toman de la app corriendo en desarrollo; las escenas están en `Presentacion.jsx`.
