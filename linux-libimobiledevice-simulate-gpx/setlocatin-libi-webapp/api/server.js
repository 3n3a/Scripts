const { spawn } = require('child_process');
const cors = require('cors');

const express = require('express')
const app = express()
const port = 8001

app.use(express.json());
app.use(cors({
  origin: '*',
  optionsSuccessStatus: 200
}));
app.use(express.static('../public'))

app.post('/', (req, res) => {
  console.log(`lat: ${req.body.lat} long: ${req.body.lng}`);
  const cmd = spawn('idevicesetlocation', ['--', req.body.lat, req.body.lng]);
  cmd.stdout.on('data', (data) => {
    console.log(`stdout: ${data}`);
  });
  cmd.stderr.on('data', (data) => {
    console.error(`stderr: ${data}`);
  });

  cmd.on('close', (code) => {
    console.log(`child process exited with code ${code}`);
  });
  res.send('Complete')
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
