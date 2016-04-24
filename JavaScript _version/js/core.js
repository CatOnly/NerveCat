/** 
 *	Author: CatOnly
 *	Welcome to my github
 *	https://github.com/CatOnly
 */

// -- Main Functions ------------------------------------------------------------------
var G          = new GlobalVar(1, 0.3);  // easy:0.7 standard:0.3 hard:0.1
var stage      = new createjs.Stage("theStage");
var scoreBoard = CreateScoreBoard(stage);
var gameArea   = CreateGameArea(stage);
var beginView  = CreateBeginView(stage);
var winView    = CreateWinView(stage);
var loseView   = CreateLoseView(stage);

createjs.Ticker.setFPS(10);
createjs.Ticker.addEventListener("tick", stage);
stage.enableMouseOver(10);

// -- Functions
// -- Circles Functions ---------------------------------------------------------------
function addCircles(parent) {
    var interval = 8;
    var radius = 25;
    var offsetX = radius*2 + interval;
    var x = radius;
    var y = radius;
    var cIndexX = parseInt(G.ROW_MAX / 2);
    var cIndexY = parseInt(G.COL_MAX / 2);
    for (var i = 0; i < G.ROW_MAX; i++, y+=(2*radius)){
        x = (i % 2) == 0 ? radius : offsetX;
        for (var j = 0; j < G.COL_MAX; j++, x+=(2*radius+interval)) {
            var circle = new Circle(x, y, i, j, radius);
            circle.addEventListener("click", clickCircle);

            if (Math.random() < G.GAME_LEVER && i != cIndexX && j != cIndexY) {
                setState(circle, G.STATE_SELECTED)
            } else {
                setState(circle, G.STATE_NORMAL)
            }

            G.ALL_OBJECT[i][j] = circle;
            parent.addChild(G.ALL_OBJECT[i][j]);
        }
    }
}
function removeAllCirclesListener() {
	for (var i = 0; i < G.ROW_MAX; i++) {
		for (var j = 0; j < G.COL_MAX; j++) {
			G.ALL_OBJECT[i][j].removeEventListener("click", clickCircle);
		}
	}
}
function clickCircle(event) {
	var obj = event.target;
    var curStepNum = scoreBoard.stepNum;
    if (obj.state != G.STATE_NORMAL) {
        playSound("replayhold");
    } else {
        setState(obj, G.STATE_SELECTED);
        updateCostOrPath();
        // test report
        testReportAdd();

        ++curStepNum;
        scoreBoard.curScore.text = "已走 " + curStepNum + " 步";

        playSound("click");
        G.THE_ONE.catGo();
        if (G.THE_ONE.who.isBoundary()) {
            gameOver();
            return;
        }
        updateCostOrPath();
        if (G.IS_CIRCLE) {
            G.THE_ONE.catIsAngry();
        }
        // test report
        testReportAdd();
    }
    scoreBoard.stepNum = curStepNum;
}
// set Circles state
// it also can change suitable color for new state
function setState(obj, state) {
    var color = ["#B5B5B5", "#FF754F", "#B5B5B5"];
    obj.state = state;
    obj.graphics.beginFill(color[obj.state]);
    obj.graphics.drawCircle(obj.px, obj.py, obj.radius);
    obj.graphics.endFill();
}

// -- View Listener Functions ----------------------------------------------------------
function lightReplayWord(event) {
	event.target.color = "#FFF";
	event.target.shadow = new createjs.Shadow("#000", 0, 0, 10)
}
function darkReplayWord(event) {
	playSound("replayhold");
	event.target.color = "#000";
	event.target.shadow = new createjs.Shadow("#FFF", 0, 0, 10)
}
function magnifyBtn(event) {
	event.target.x = 125;
	event.target.y = 620;
	offsetSize(event.target, 1.2)
}
function minifyBtn(event) {
	playSound("replayhold");
	offsetSize(event.target, 1);
	event.target.x = 125;
	event.target.y = 620;
}
function setPositionXY(obj, x, y) {
	obj.x = x;
	obj.y = y;
}
function offsetSize(obj, multiple) {
	obj.scaleX = multiple;
	obj.scaleY = multiple
}
function bestScore(score) {
	return score == 80 ? "?" : score
}
function playSound(id) {
	var music = document.getElementById(id);
	music.play();
}
function soundPlayOrPause() {
	var music = document.getElementById('bgm');
    playSound("replayhold");
	if (music.paused) {
		music.play();
        scoreBoard.bgmPlay.visible = true;
        scoreBoard.bgmPause.visible = false;
	} else {
		music.pause();
        scoreBoard.bgmPlay.visible = false;
        scoreBoard.bgmPause.visible = true;
	}
}

// -- View Functions
// -- ScoreBoard ---------------------------------------------------------------------
function CreateScoreBoard(parent){
    var obj = new createjs.Container();

    obj.stepNum    = 0;  // Count the player's step
    obj.minStepNum = 80; // The Best Score of player' step

    obj.curScore   = new createjs.Text("已走 " + obj.stepNum + " 步", "bold 25px Aria", "#FFF");
    obj.greatScore = new createjs.Text("最高记录 ? 步", "bold 25px Aria", "#FFF");

    obj.replay     = new createjs.Text("重\n玩", "25px Aria", "#FFF");
    obj.bgmPlay    = new createjs.Bitmap("./img/play.png");
    obj.bgmPause   = new createjs.Bitmap("./img/pause.png");

    obj.background = new createjs.Bitmap("./img/bg.png");

    obj.reflashScore = function(){
        this.curScore.text    = "已走 " + this.stepNum + " 步";
        this.greatScore.text = "最高记录 " + bestScore(this.minStepNum) + " 步";
    };
    initialScoreBoard(obj);
    addScoreBoard(obj);
    parent.addChild(obj);
    return obj;
}
function initialScoreBoard(obj) {
    obj.replay.shadow   = new createjs.Shadow("#000", 0, 0, 10);
    obj.curScore.shadow = new createjs.Shadow("#000", 0, 0, 10);
    obj.greatScore.shadow  = new createjs.Shadow("#000", 0, 0, 10);

    obj.bgmPause.visible = false;
    setPositionXY(obj.replay, 232, 220);
	setPositionXY(obj.greatScore, 350, 150);
	setPositionXY(obj.curScore, 40, 150);
	setPositionXY(obj.bgmPlay, 15, 20);
	setPositionXY(obj.bgmPause, 15, 20);
    offsetSize(obj.background, (565.0 / 640));
}
function addScoreBoard(obj) {
    obj.bgmPlay.addEventListener("click", soundPlayOrPause);
    obj.bgmPause.addEventListener("click", soundPlayOrPause);
    obj.replay.addEventListener("click", begin);
    obj.replay.addEventListener("rollout", lightReplayWord);
    obj.replay.addEventListener("rollover", darkReplayWord);

    obj.addChild(obj.background);
    obj.addChild(obj.replay);
    obj.addChild(obj.curScore);
    obj.addChild(obj.greatScore);
    obj.addChild(obj.bgmPlay);
    obj.addChild(obj.bgmPause);
}

// -- BeginView ----------------------------------------------------------------------
function CreateBeginView(parent){
    var obj       = new createjs.Container();
    obj.title     = new createjs.Bitmap("./img/title.png");
    obj.miaoLeft  = new createjs.Bitmap("./img/miaoLeft.png");
    obj.miaoRight = new createjs.Bitmap("./img/miaoRight.png");
    obj.startBtn  = new createjs.Bitmap("./img/start.png");

    initialBeginView(obj);
    addBeginView(obj, parent);
    parent.addChild(obj);

    // depend on global variable stage
    addBeginViewAnim(obj);
    return obj;
}
function initialBeginView (obj) {
	offsetSize(obj.title, 1.2);
	offsetSize(obj.miaoLeft, 1.2);
	offsetSize(obj.miaoRight, 1.2);
    setPositionXY(obj, 0, 0);
    setPositionXY(obj.title, 40, 60);
    setPositionXY(obj.miaoLeft, 0, 200);
    setPositionXY(obj.miaoRight, 0, 200);
    setPositionXY(obj.startBtn, 125, 620);
}
function addBeginView(obj, parent) {
	obj.addChild(obj.title);
	obj.addChild(obj.miaoLeft);
	obj.addChild(obj.miaoRight);

    offsetSize(obj.startBtn, 1.2);
    obj.startBtn.visible = true;
    obj.startBtn.addEventListener("rollover", minifyBtn);
    obj.startBtn.addEventListener("rollout", magnifyBtn);
    obj.startBtn.addEventListener("click", begin);
    parent.addChild(obj.startBtn);
}
// The around action of cat in the welcome view
function addBeginViewAnim(obj) {
    var endPosition   = 300;
    var beginPosition = 10;
    var speedX  = 10;
    var tempObj = obj.miaoLeft;
    obj.miaoLeft.x  = beginPosition;
    obj.miaoRight.x = endPosition;
    obj.miaoLeft.visible  = true;
    obj.miaoRight.visible = false;
    createjs.Ticker.addEventListener("tick", function() {
        if (!beginView.isVisible()) {
            obj.miaoLeft = null;
            obj.miaoRight = null;
            return;
        }
        if (tempObj.x > endPosition) {
            tempObj.visible = false;
            tempObj.x = beginPosition;
            tempObj = obj.miaoRight;
            tempObj.visible = true;
            speedX = -Math.abs(speedX)
        } else if (tempObj.x < beginPosition) {
            tempObj.visible = false;
            tempObj.x = endPosition;
            tempObj = obj.miaoLeft;
            tempObj.visible = true;
            speedX = Math.abs(speedX)
        }
        tempObj.x += speedX;
        stage.update();
    });
}

// -- BeginView ----------------------------------------------------------------------
function CreateWinView(parent){
    var obj         = new createjs.Container();
    obj.youWin      = new createjs.Bitmap("./img/victory.png");
    obj.winnerSpeak = new createjs.Text("","bold 36px Aria", "#000");
    initialWinView(obj);
    addWinView(obj);
    parent.addChild(obj);
    return obj;
}
function initialWinView(obj){
    obj.winnerSpeak.lineHeight = 50;
	setPositionXY(obj.youWin, 60, 210);
	setPositionXY(obj.winnerSpeak, 120, 370);
	obj.visible = false;
}
function addWinView(obj) {
	obj.addChild(obj.youWin);
	obj.addChild(obj.winnerSpeak);
}
// -- LoseView -----------------------------------------------------------------------

function CreateLoseView(parent){
    var obj = new createjs.Container();
    obj.youLose     = new createjs.Bitmap("./img/failed.png");
    obj.loserSpeak  = new createjs.Text("","bold 36px Aria", "#000");
    initialLoseView(obj);
    addLoseView(obj);
    parent.addChild(obj);
    return obj;
}
function initialLoseView (obj) {
	setPositionXY(obj.youLose, 60, 210);
	setPositionXY(obj.loserSpeak, 120, 420);
	obj.visible = false;
}
function addLoseView(obj) {
	obj.addChild(obj.youLose);
	obj.addChild(obj.loserSpeak);
}
// -- WinView ------------------------------------------------------------------------
function CreateGameArea(parent){
    var obj = new createjs.Container();
    setPositionXY(obj, 10, 320);
    parent.addChild(obj);
    return obj;
}

// -- Core Action Functions ----------------------------------------------------------
function begin() {
    scoreBoard.stepNum = 0;
    scoreBoard.reflashScore();

	gameArea.removeAllChildren();

	beginView.visible = false;
    beginView.startBtn.visible = false;

    winView.visible = false;
	loseView.visible = false;
	addCircles(gameArea);

    // The only one cat
    G.THE_ONE = new Cat(G.ROW_MAX,G.COL_MAX);
    G.THE_ONE.addCat(gameArea);

    playSound("click");
	updateCostOrPath();

	// add test report
	testReportAdd();
}
function gameOver() {
    testReportAdd();

	playSound("lose");
	removeAllCirclesListener();
    beginView.startBtn.visible = true;
	winView.visible = false;
    loseView.loserSpeak.text = loserOption();
	loseView.visible = true;
    scoreBoard.reflashScore();
    scoreBoard.stepNum = 0;
}
function victory() {
	playSound("win");
	removeAllCirclesListener();

    var minStepNum = scoreBoard.minStepNum;
    var curStepNum = scoreBoard.stepNum;
    scoreBoard.minStepNum = minStepNum > curStepNum ? curStepNum : minStepNum;
    scoreBoard.reflashScore();
    beginView.startBtn.visible = true;

    loseView.visible = false;
	winView.visible  = true;
    winView.winnerSpeak.text = "本局记录 " + curStepNum + " 步\n最高记录 " + bestScore(curStepNum) + " 步";

    scoreBoard.stepNum = 0;
}
function loserOption() {
	var text;
	switch (parseInt(Math.random() * 10) % 5) {
	    case 0: text = "愚蠢的人类哟 ！";break;
	    case 1: text = "他跑了？这不科学 ！";break;
	    case 2: text = "这喵果然厉害 ！";break;
	    case 3: text = "这 ？？！！！";break;
	    case 4: text = "您的智商已欠费..";break;
	    case 5: text = "元芳你怎么看 ？";break;
	    default:text = "愚蠢的人类哟 ！"
	}
	return text;
}

// -- Test Code ----------------------------------------------------------------------
var reportArea = document.getElementById("testInfro");
var testArea = document.getElementById("testArea");
if (G.FLAG) {
	testArea.style.visibility = "visible";
}
function testReportAdd() {
	if (G.FLAG) {
        reportArea.innerHTML = '';
		testDraw("最短路径图：", reportArea, true);
        testDraw("最大通路图：", reportArea, false);
	}
}
function testDraw(name, reportArea, isPath){
    reportArea.innerHTML += '<h3>'+ name + '</h3>';
    var i,j;
    for (i = 0; i < G.ROW_MAX; i++) {
        reportArea.innerHTML += '<div>';
        if (i % 2 != 0) {
            reportArea.innerHTML += '<button style="visibility: hidden;width: 30px">占</button>';
        }
        for (j = 0; j < G.COL_MAX; j++) {
            var btnClass = '';
            if (G.ALL_OBJECT[i][j].state == G.STATE_SELECTED) {
                btnClass = 'class="tSelectBtn"';
            }else if(G.ALL_OBJECT[i][j].state == G.STATE_CAT) {
                btnClass = 'class="tCatBtn"';
            }
            var content = isPath ? G.ALL_OBJECT[i][j].path: G.ALL_OBJECT[i][j].cost;
            reportArea.innerHTML = reportArea.innerHTML + '<button '+ btnClass +'>' + content + '</button>';
        }
        reportArea.innerHTML += '</div>';
    }
}