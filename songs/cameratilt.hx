// Original script by SenTCM
// Translated into CNE HScript by clairedeluneee
var config:Dynamic = {
	intensity: 1,
	speed: 1,
	scaling: {
		game: 1.07,
		hud: 1.02
	},
	zoom: 0.65,
	offset: 10,
	opponentTilt: true
};

var offsetTable:Array<Dynamic> = [
	{angle: 0 - config.intensity, x: config.offset, y: config.offset},
	{angle: 0, x: 0, y: 0 - config.offset},
	{angle: 0, x: 0, y: config.offset},
	{angle: config.intensity, x: config.offset, y: 0 - config.offset},
];

var noOffset:Dynamic = {angle: 0, x: 0, y: 0};

function postCreate():Void {
	camGame.flashSprite.scaleX = camGame.flashSprite.scaleY = config.scaling.game;
	camHUD.flashSprite.scaleX = camHUD.flashSprite.scaleY = config.scaling.hud;

	defaultCamZoom = config.zoom;
}

var tween:FlxTween = null;
var hasIdled:Bool = true;

function onPlayerHit(event:NoteHitEvent):Void {
	if (curCameraTarget != 1)
		return;
	if (event.note.isSustainNote)
		return;

	doMove(event.note.noteData);
}

function onDadHit(event:NoteHitEvent):Void {
	if (curCameraTarget != 0)
		return;
	if (event.note.isSustainNote)
		return;
	if (!config.opponentTilt)
		return;

	doMove(event.note.noteData);
}

function update() {
	var condition:Int = 0;

	if (dad.animation.curAnim.name == "idle" && curCameraTarget == 0)
		condition++;
	if (curCameraTarget == 0 && !config.opponentTilt)
		condition++;
	if (bf.animation.curAnim.name == "idle" && curCameraTarget == 1)
		condition++;

	if (condition > 0 && !hasIdled)
		doMove(null);

	camHUD.angle = camGame.angle;
}

function doMove(pos) {
	if (tween != null) {
		tween.cancel();
		tween = null;
	}

	if (pos == null) {
		hasIdled = true;
		tween = FlxTween.tween(camGame, noOffset, config.speed, {ease: FlxEase.quartOut});
		return;
	}

	hasIdled = false;
	tween = FlxTween.tween(camGame, offsetTable[pos % 4], config.speed, {ease: FlxEase.quartOut});
}
