import funkin.game.Character;
import funkin.game.StrumLine;
import haxe.ds.StringMap;
import flixel.FlxG;

var CAMERA_FIX_X:Float = 0;
var CAMERA_FIX_Y:Float = 0;

var originalDad:Character;
var originalBF:Character;
var originalGF:Character;
var originalLineCharacters:Array<Array<Character>> = [];

var preloadedCharacters:StringMap<Character> = new StringMap<Character>();
var preloadedBaselines:StringMap<Dynamic> = new StringMap<Dynamic>();

var lastDadIcon:String = "";
var lastBFIcon:String = "";
var lastDadHealthColor:Int = -1;
var lastBFHealthColor:Int = -1;

function getKey(lineIndex:Int, charIndex:Int, id:String, isPlayer:Bool):String
{
    return lineIndex
        + "::"
        + charIndex
        + "::"
        + id
        + "::"
        + (isPlayer ? "1" : "0");
}

function getStageSlotForLine(line:StrumLine):String
{
    if (line == null)
        return "";

    if (line == playerStrums)
        return "boyfriend";

    if (line == cpuStrums)
        return "dad";

    if (line.data != null)
    {
        if (Reflect.hasField(
            line.data,
            "position"
        ))
        {
            var position =
                Reflect.field(
                    line.data,
                    "position"
                );

            if (position != null)
            {
                var positionString =
                    Std.string(position);

                if (positionString.length > 0)
                    return positionString;
            }
        }

        if (Reflect.hasField(
            line.data,
            "type"
        ))
        {
            var typeValue =
                Reflect.field(
                    line.data,
                    "type"
                );

            if (typeValue != null)
            {
                var typeString =
                    Std.string(typeValue);

                if (typeString == "0")
                    return "dad";

                if (typeString == "1")
                    return "boyfriend";

                if (typeString == "2")
                    return "girlfriend";

                if (typeString == "OPPONENT")
                    return "dad";

                if (typeString == "PLAYER")
                    return "boyfriend";
            }
        }
    }

    return "";
}

function getLineIndex(slot:String):Int
{
    if (strumLines == null ||
        strumLines.members == null ||
        slot == null ||
        slot.length == 0)
        return -1;

    if (slot == "0" || slot == "dad")
    {
        if (cpuStrums != null)
            return strumLines.members.indexOf(
                cpuStrums
            );

        return -1;
    }

    if (slot == "1" ||
        slot == "bf" ||
        slot == "boyfriend" ||
        slot == "player")
    {
        if (playerStrums != null)
            return strumLines.members.indexOf(
                playerStrums
            );

        return -1;
    }

    if (slot == "2" ||
        slot == "gf" ||
        slot == "girlfriend")
    {
        if (gf != null)
        {
            for (i in 0...strumLines.members.length)
            {
                var gfLine = strumLines.members[i];
                if (gfLine != null && gfLine.characters != null && gfLine.characters.indexOf(gf) != -1)
                    return i;
            }
        }

        for (i in 0...strumLines.members.length)
        {
            var line =
                strumLines.members[i];

            if (line == null)
                continue;

            if (getStageSlotForLine(line) ==
                "girlfriend")
                return i;
        }

        return -1;
    }

    var numeric =
        Std.parseInt(slot);

    if (numeric != null)
    {
        if (numeric >= 0 &&
            numeric < strumLines.members.length)
            return numeric;

        return -1;
    }

    if (StringTools.startsWith(
        slot,
        "line"
    ))
    {
        var lineNumber =
            Std.parseInt(
                slot.substr(4)
            );

        if (lineNumber != null &&
            lineNumber >= 0 &&
            lineNumber < strumLines.members.length)
            return lineNumber;
    }

    for (i in 0...strumLines.members.length)
    {
        var line =
            strumLines.members[i];

        if (line == null)
            continue;

        if (getStageSlotForLine(line) ==
            slot)
            return i;
    }

    return -1;
}

function isPlayerLine(line:StrumLine):Bool
{
    if (line == null)
        return false;

    if (line == playerStrums)
        return true;

    if (line == cpuStrums)
        return false;

    return !line.opponentSide;
}

function getCharacterFlipMode(line:StrumLine, charID:String):Bool
{
    if (line == null)
        return false;

    if (stage == null)
        return isPlayerLine(line);

    var positionName = getStageSlotForLine(line);
    var defaultFlip = line == playerStrums;

    if (line.data != null && Reflect.hasField(line.data, "type"))
    {
        var lineType = Std.string(Reflect.field(line.data, "type"));
        defaultFlip = lineType == "1" || lineType.toUpperCase() == "PLAYER";
    }

    if (stage.characterPoses != null &&
        charID != null &&
        stage.characterPoses[charID] != null)
    {
        positionName = charID;
    }

    return stage.isCharFlipped(positionName, defaultFlip);
}

function compactMembers():Void
{
    if (members == null)
        return;

    var i:Int = 0;

    while (i < members.length)
    {
        if (members[i] == null)
        {
            members.splice(
                i,
                1
            );

            continue;
        }

        i++;
    }
}

function removeMemberSafely(obj:Dynamic):Void
{
    if (obj == null ||
        members == null)
        return;

    var index =
        members.indexOf(
            obj
        );

    if (index >= 0)
    {
        remove(
            obj,
            true
        );
    }
}

function saveCharacterBaseline(key:String, char:Character):Void
{
    if (char == null ||
        key == null ||
        key.length == 0)
        return;

    if (preloadedBaselines.exists(key))
        return;

    preloadedBaselines.set(
        key,
        {
            x: char.x,
            y: char.y,

            scrollX:
                char.scrollFactor != null
                    ? char.scrollFactor.x
                    : 1,

            scrollY:
                char.scrollFactor != null
                    ? char.scrollFactor.y
                    : 1,

            scaleX:
                char.scale != null
                    ? char.scale.x
                    : 1,

            scaleY:
                char.scale != null
                    ? char.scale.y
                    : 1,

            cameraOffsetX:
                char.cameraOffset != null
                    ? char.cameraOffset.x
                    : 0,

            cameraOffsetY:
                char.cameraOffset != null
                    ? char.cameraOffset.y
                    : 0,

            skewX:
                char.skew != null
                    ? char.skew.x
                    : 0,

            skewY:
                char.skew != null
                    ? char.skew.y
                    : 0,

            alpha:
                char.alpha,

            angle:
                char.angle,

            zoomFactor:
                char.zoomFactor
        }
    );
}

function resetCharacterBaseline(key:String, char:Character):Void
{
    if (char == null ||
        key == null ||
        key.length == 0)
        return;

    if (!preloadedBaselines.exists(key))
        return;

    var base =
        preloadedBaselines.get(
            key
        );

    if (base == null)
        return;

    char.x =
        base.x;

    char.y =
        base.y;

    if (char.scrollFactor != null)
    {
        char.scrollFactor.set(
            base.scrollX,
            base.scrollY
        );
    }

    if (char.scale != null)
    {
        char.scale.set(
            base.scaleX,
            base.scaleY
        );
    }

    if (char.cameraOffset != null)
    {
        char.cameraOffset.set(
            base.cameraOffsetX,
            base.cameraOffsetY
        );
    }

    if (char.skew != null)
    {
        char.skew.set(
            base.skewX,
            base.skewY
        );
    }

    char.alpha =
        base.alpha;

    char.angle =
        base.angle;

    char.zoomFactor =
        base.zoomFactor;
}

function postCreate()
{
    originalDad = dad;
    originalBF = boyfriend;
    originalGF = gf;

    originalLineCharacters = [];

    lastDadIcon = "";
    lastBFIcon = "";
    lastDadHealthColor = -1;
    lastBFHealthColor = -1;

    if (strumLines != null &&
        strumLines.members != null)
    {
        for (line in strumLines.members)
        {
            if (line != null &&
                line.characters != null)
            {
                originalLineCharacters.push(
                    line.characters.copy()
                );
            }
            else
            {
                originalLineCharacters.push(
                    []
                );
            }
        }
    }

    if (events == null)
        return;

    for (event in events)
    {
        if (event == null ||
            event.name != "Swap Character" ||
            event.params == null ||
            event.params.length < 3)
            continue;

        var slot =
            Std.string(
                event.params[0]
            );

        var charIndex =
            Std.parseInt(
                Std.string(
                    event.params[1]
                )
            );

        var charID =
            Std.string(
                event.params[2]
            );

        if (charIndex == null ||
            charIndex < 0 ||
            charID == null ||
            charID.length == 0)
            continue;

        var lineIndex =
            getLineIndex(
                slot
            );

        if (lineIndex < 0 ||
            lineIndex >= strumLines.members.length)
            continue;

        var line =
            strumLines.members[lineIndex];

        if (line == null ||
            line.characters == null ||
            charIndex >= line.characters.length)
            continue;

        var isPlayer =
            getCharacterFlipMode(
                line,
                charID
            );

        var key =
            getKey(
                lineIndex,
                charIndex,
                charID,
                isPlayer
            );

        if (preloadedCharacters.exists(key))
            continue;

        var newChar =
            preloadCharacter(
                charID,
                isPlayer
            );

        if (newChar == null)
            continue;

        saveCharacterBaseline(
            key,
            newChar
        );

        newChar.visible = false;
        newChar.active = false;
        newChar.exists = false;

        add(
            newChar
        );

        preloadedCharacters.set(
            key,
            newChar
        );

        newChar.drawComplex(
            FlxG.camera
        );
    }

    compactMembers();
}

function preloadCharacter(charID:String, isPlayer:Bool):Character
{
    try
    {
        var char =
            new Character(
                0,
                0,
                charID,
                isPlayer,
                true,
                false
            );

        char.visible = false;
        char.active = false;
        char.exists = false;

        return char;
    }
    catch (e:Dynamic)
    {
        return null;
    }
}

function cleanupCharacters()
{
    if (strumLines != null &&
        strumLines.members != null)
    {
        for (lineIndex in 0...strumLines.members.length)
        {
            var line =
                strumLines.members[lineIndex];

            if (line == null)
                continue;

            if (lineIndex <
                originalLineCharacters.length)
            {
                line.characters =
                    originalLineCharacters[
                        lineIndex
                    ].copy();
            }
        }
    }

    if (cpuStrums != null &&
        cpuStrums.characters != null &&
        cpuStrums.characters.length > 0)
    {
        cpuStrums.characters[0] =
            originalDad;
    }

    if (playerStrums != null &&
        playerStrums.characters != null &&
        playerStrums.characters.length > 0)
    {
        playerStrums.characters[0] =
            originalBF;
    }

    dad =
        originalDad;

    boyfriend =
        originalBF;

    bf =
        originalBF;

    gf =
        originalGF;

    if (preloadedCharacters != null)
    {
        for (char in preloadedCharacters.iterator())
        {
            if (char == null)
                continue;

            var index =
                members.indexOf(
                    char
                );

            if (index >= 0)
            {
                remove(
                    char,
                    true
                );
            }

            char.visible = false;
            char.active = false;
            char.exists = false;

            char.kill();
            char.destroy();
        }

        preloadedCharacters.clear();
    }

    preloadedBaselines.clear();

    originalLineCharacters = [];

    lastDadIcon = "";
    lastBFIcon = "";
    lastDadHealthColor = -1;
    lastBFHealthColor = -1;

    compactMembers();
}

function onStateSwitch(event)
{
    cleanupCharacters();
}

function destroy()
{
    cleanupCharacters();
}

function getStrumline(slot:String):StrumLine
{
    if (strumLines == null ||
        strumLines.members == null)
        return null;

    var lineIndex =
        getLineIndex(
            slot
        );

    if (lineIndex < 0 ||
        lineIndex >= strumLines.members.length)
        return null;

    return strumLines.members[lineIndex];
}

function getStageSlot(slot:String):String
{
    var line =
        getStrumline(
            slot
        );

    if (line != null)
    {
        var stageSlot =
            getStageSlotForLine(
                line
            );

        if (stageSlot != null &&
            stageSlot.length > 0)
        {
            return stageSlot;
        }
    }

    return switch (slot)
    {
        case "dad":
            "dad";

        case "bf":
            "boyfriend";

        case "boyfriend":
            "boyfriend";

        case "player":
            "boyfriend";

        case "gf":
            "girlfriend";

        case "girlfriend":
            "girlfriend";

        default:
            slot;
    };
}

function applyCameraFix(char:Character):Void
{
    if (char == null)
        return;

    char.cameraOffset.x +=
        CAMERA_FIX_X;

    char.cameraOffset.y +=
        CAMERA_FIX_Y;
}

function applyCurrentStageProperties(char:Character, slot:String, index:Int):Void
{
    if (char == null ||
        stage == null)
        return;

    var stageSlot =
        getStageSlot(
            slot
        );

    var charIndex =
        members.indexOf(
            char
        );

    if (charIndex >= 0)
    {
        remove(
            char,
            true
        );
    }

    stage.applyCharStuff(
        char,
        stageSlot,
        index
    );

    applyCameraFix(
        char
    );
}

function replaceCharacter(slot:String, index:Int, newID:String)
{
    if (strumLines == null ||
        strumLines.members == null)
        return;

    var lineIndex =
        getLineIndex(
            slot
        );

    if (lineIndex < 0 ||
        lineIndex >= strumLines.members.length)
        return;

    var strum =
        strumLines.members[lineIndex];

    if (strum == null ||
        strum.characters == null ||
        index < 0 ||
        index >= strum.characters.length)
        return;

    var oldChar =
        strum.characters[index];

    if (oldChar == null)
        return;

    var isPlayer =
        getCharacterFlipMode(
            strum,
            newID
        );

    var key =
        getKey(
            lineIndex,
            index,
            newID,
            isPlayer
        );

    if (!preloadedCharacters.exists(key))
        return;

    var newChar =
        preloadedCharacters.get(
            key
        );

    if (newChar == null ||
        newChar == oldChar)
        return;

    if (oldChar.curCharacter ==
        newChar.curCharacter)
        return;

    var oldAnim =
        oldChar.getAnimName();

    var oldFrame:Int = 0;

    if (oldChar.animation != null &&
        oldChar.animation.curAnim != null)
    {
        oldFrame =
            oldChar.animation.curAnim.curFrame;
    }

    resetCharacterBaseline(
        key,
        newChar
    );

    newChar.visible = false;
    newChar.active = true;
    newChar.exists = true;

    var existingNewIndex =
        members.indexOf(
            newChar
        );

    if (existingNewIndex >= 0)
    {
        remove(
            newChar,
            true
        );
    }

    if (stage != null)
    {
        applyCurrentStageProperties(
            newChar,
            slot,
            index
        );
    }
    else
    {
        add(
            newChar
        );
    }

    var oldIndex =
        members.indexOf(
            oldChar
        );

    if (oldIndex >= 0)
    {
        remove(
            oldChar,
            true
        );
    }

    strum.characters[index] =
        newChar;

    newChar.visible = true;
    newChar.active = true;
    newChar.exists = true;

    if (oldAnim != null &&
        newChar.hasAnim(oldAnim))
    {
        newChar.playAnim(
            oldAnim,
            true,
            oldChar.lastAnimContext,
            false,
            oldFrame
        );
    }
    else
    {
        newChar.dance();
    }

    if (index == 0)
    {
        if (strum == cpuStrums)
        {
            dad =
                newChar;
        }
        else if (strum == playerStrums)
        {
            boyfriend =
                newChar;

            bf =
                newChar;
        }
        else if (oldChar == gf)
        {
            gf = newChar;
        }
    }

    compactMembers();

    refreshIcons();

    if (index == 0)
    {
        moveCamera(
            true
        );
    }

    refreshHealthBar();
}

function refreshIcons()
{
    if (iconP2 != null &&
        dad != null)
    {
        var dadIcon =
            dad.getIcon();

        if (dadIcon != lastDadIcon)
        {
            iconP2.setIcon(
                dadIcon
            );

            lastDadIcon =
                dadIcon;
        }
    }

    if (iconP1 != null &&
        boyfriend != null)
    {
        var bfIcon =
            boyfriend.getIcon();

        if (bfIcon != lastBFIcon)
        {
            iconP1.setIcon(
                bfIcon
            );

            lastBFIcon =
                bfIcon;
        }
    }
}

function refreshHealthBar()
{
    if (healthBar == null ||
        dad == null ||
        boyfriend == null)
        return;

    var dadColor =
        dad.iconColor != null
            ? dad.iconColor
            : 0xFFFF0000;

    var bfColor =
        boyfriend.iconColor != null
            ? boyfriend.iconColor
            : 0xFF66FF33;

    if (dadColor != lastDadHealthColor ||
        bfColor != lastBFHealthColor)
    {
        healthBar.createFilledBar(
            dadColor,
            bfColor
        );

        lastDadHealthColor =
            dadColor;

        lastBFHealthColor =
            bfColor;
    }

    healthBar.updateBar();
}

function onEvent(e)
{
    if (e == null ||
        e.event == null ||
        e.event.name != "Swap Character")
        return;

    if (e.event.params == null ||
        e.event.params.length < 3)
        return;

    var slot =
        Std.string(
            e.event.params[0]
        );

    var index =
        Std.parseInt(
            Std.string(
                e.event.params[1]
            )
        );

    var id =
        Std.string(
            e.event.params[2]
        );

    if (index == null ||
        index < 0 ||
        id == null ||
        id.length == 0)
        return;

    replaceCharacter(
        slot,
        index,
        id
    );
}