var shader:CustomShader = new CustomShader("vcr");

function postCreate() {
    camGame.addShader(shader);
    camHUD.addShader(shader);

    shader.rOffset = 0.0025;
    shader.gOffset = 0.0075;
    shader.bOffset = 0.005;
}

function postUpdate(delta) {
shader.rOffset = 0.0025 * cpu.vocals.amplitude;
shader.gOffset = 0;
shader.bOffset = 0.0025 * cpu.vocals.amplitude * -1;
}
