/**
 *	Author: CatOnly
 *	Welcome to my github
 *	https://github.com/CatOnly
 */

// -- Global Class ----------------------------------------------------------------------
function GlobalVar(flag, gameLever) {
    this.FLAG = flag;	// Test action only is 0 or 1

    this.STATE_NORMAL = 0;    // Normal Cricle state
    this.STATE_SELECTED = 1;    // Selected Cricle state
    this.STATE_CAT = 2;	// Cat state

    this.THE_ONE = null;
    this.ALL_OBJECT = [[], [], [], [], [], [], [], [], []];
    this.ROW_MAX = 9;	// The Max row number
    this.COL_MAX = 9;	// The Max column number
    this.IS_CIRCLE = 0;    // Record whether the cat is stranded
    this.GAME_LEVER = gameLever;	// The game lever easy to hard: 0.9 - 0.1
}

// -- The Core Class Of Circle Start ---------------------------------------------------
function Circle(x, y, row, col, radius) {
    // make class Circle  extends class Shape
    createjs.Shape.call(this);

    // it just store circle's position, can't set circle's position
    this.px = x;
    this.py = y;

    // the Circle's index number
    this.row = row;
    this.col = col;

    this.radius = radius;

    this.cost = -10;
    this.path = -10;
    this.state = G.STATE_NORMAL;
}
// The class Circle is extends createjs's Shape function
Circle.prototype = new createjs.Shape();

//  judge if the circle is in Boundary
Circle.prototype.isBoundary = function() {
    if (this.row == 0 || this.col == 0 || this.row == G.ROW_MAX - 1 || this.col == G.COL_MAX - 1) {
        return 1;
    } else {
        return 0;
    }
};

//  judge if the cat is stranded and the player will win this game
Circle.prototype.isCircle = function(){
    var allConnectCircles = this.getAllConnectCircles();
    var count = 0;
    for (var i = 0; i < 6; i++) {
        if (allConnectCircles[i].path >= 8) {
            ++count;
        }
    }
    return count == 6 ? 1 : 0;
};

// compared by cost
Circle.prototype.isLessThan = function(circle) {
    return this.cost < circle.cost ? 1 : 0;
};

// compared by path
Circle.prototype.isLongerThan = function(circle) {
    return this.path > circle.path ? 1 : 0;
};

// choose the measures that make cat where to go
Circle.prototype.chooseWay = function(circle){
    if (G.IS_CIRCLE) {
        return this.isLessThan(circle);
    } else {
        return this.isLongerThan(circle);
    }
};
Circle.prototype.getMaxCost = function() {
    if (this.state == G.STATE_SELECTED) {
        this.cost = 10;
    }else if (this.isBoundary()) {
        this.cost = -1;
    }else{
        this.cost = this.getAllConnectCanGo().length;
    }
};

Circle.prototype.getMinPath = function() {
    if (this.state == G.STATE_SELECTED) {
        this.path = 10;
    }else if (this.isBoundary()) {
        this.path = 0;
    }else{
        var allConnectCanGo = this.getAllConnectCanGo();
        var min = 10;
        for (var i = 0; i < allConnectCanGo.length; i++) {
            var path = allConnectCanGo[i].path;
            if (path < 0) {
                path = -path;
            }
            if (path < min) {
                min = path;
            }
        }
        this.path = min + 1;
    }
};

// get current object's left object of Circle class
Circle.prototype.getLeft = function(){
    var x = this.row;
    var y = this.col;
    --y;
    return G.ALL_OBJECT[x][y];
};
Circle.prototype.getUpperLeft = function(){
    var x = this.row;
    var y = this.col;
    --x;
    y = x % 2 == 0 ? y : y - 1;
    return G.ALL_OBJECT[x][y];
};
Circle.prototype.getUpperRight = function(){
    var x = this.row;
    var y = this.col;
    --x;
    y = x % 2 == 0 ? y + 1 : y;
    return G.ALL_OBJECT[x][y];
};
Circle.prototype.getRight = function(){
    var x = this.row;
    var y = this.col;
    ++y;
    return G.ALL_OBJECT[x][y];
};
Circle.prototype.getBottomRight = function(){
    var x = this.row;
    var y = this.col;
    ++x;
    y = x % 2 == 0 ? y + 1 : y;
    return G.ALL_OBJECT[x][y];
};
Circle.prototype.getBottomLeft = function(){
    var x = this.row;
    var y = this.col;
    ++x;
    y = x % 2 == 0 ? y : y - 1;
    return G.ALL_OBJECT[x][y];
};

Circle.prototype.getAllConnectCanGo = function(){
    var a = new Array();
    if (this.getLeft().state == G.STATE_NORMAL) {
        a.push(this.getLeft());
    }
    if (this.getUpperLeft().state == G.STATE_NORMAL) {
        a.push(this.getUpperLeft());
    }
    if (this.getUpperRight().state == G.STATE_NORMAL) {
        a.push(this.getUpperRight());
    }
    if (this.getRight().state == G.STATE_NORMAL) {
        a.push(this.getRight());
    }
    if (this.getBottomRight().state == G.STATE_NORMAL) {
        a.push(this.getBottomRight());
    }
    if (this.getBottomLeft().state == G.STATE_NORMAL) {
        a.push(this.getBottomLeft());
    }
    return a;
};

Circle.prototype.getAllConnectCircles = function(){
    var a = new Array();
    a.push(this.getLeft());
    a.push(this.getUpperLeft());
    a.push(this.getUpperRight());
    a.push(this.getRight());
    a.push(this.getBottomRight());
    a.push(this.getBottomLeft());
    return a;
};

function updateCostOrPath() {
    G.IS_CIRCLE = G.THE_ONE.who.isCircle();
    if(!G.IS_CIRCLE){
        updatePath();
    }else{
        updateCost();
    }
}

function updateCost() {
    for (var i = 0; i < G.ROW_MAX; i++) {
        for (var j = 0; j < G.COL_MAX; j++) {
            G.ALL_OBJECT[i][j].getMaxCost();
        }
    }
}

function updatePath() {
    // here i,j is function's variable not the for
    for (var i = 0; i < G.ROW_MAX; i++) {
        for (var j = 0; j < G.COL_MAX; j++) {
            G.ALL_OBJECT[i][j].getMinPath();
            G.ALL_OBJECT[j][i].getMinPath();
        }
    }
    for (i = 0; i < G.ROW_MAX; i++) {
        for (j = 0; j < G.COL_MAX; j++) {
            G.ALL_OBJECT[i][G.COL_MAX-1-j].getMinPath();
            G.ALL_OBJECT[j][G.ROW_MAX-1-i].getMinPath();
        }
    }
    for (i = 0; i < G.ROW_MAX; i++) {
        for (j = 0; j < G.COL_MAX; j++) {
            G.ALL_OBJECT[G.ROW_MAX-1-i][G.COL_MAX-1-j].getMinPath();
            G.ALL_OBJECT[G.COL_MAX-1-j][G.ROW_MAX-1-i].getMinPath();
        }
    }
    for (i = 0; i < G.ROW_MAX; i++) {
        for (j = 0; j < G.COL_MAX; j++) {
            G.ALL_OBJECT[G.ROW_MAX-1-i][j].getMinPath();
            G.ALL_OBJECT[G.COL_MAX-1-j][i].getMinPath();
        }
    }
}

// -- The Core Class Of Circle End -----------------------------------------------------
// -- The Core Class Of Cat ------------------------------------------------------------
function Cat(row, col) {
    this.who = G.ALL_OBJECT[parseInt(row/2)][parseInt(col/2)];
    this.who.state = G.STATE_CAT;

    // the normal display of cat
    this.normal = new createjs.Sprite(
        new createjs.SpriteSheet({
            "images": ["./img/stay.png"],
            "frames": {
                "height": 98.5,
                "width": 64,
                "count": 16
            },
            "animations": {
                "normal": [0, 15]
            }
        })
        , "normal"
    );

    // the special display when cat see it can't win the game
    this.lose = new createjs.Sprite(
        new createjs.SpriteSheet({
            "images": ["./img/weizhu.png"],
            "frames": {
                "height": 92.75,
                "width": 64,
                "count": 16
            },
            "animations": {
                "angry": [0, 14]
            }
        })
        , "angry"
    );
    // it depend on this porperty : this.normal,this.lose
    this.lose.visible = false;
    this.normal.visible = true;
    this.normal.setTransform(this.who.px, this.who.py, 1, 1, 0, 0, 0, 33, 90);
    this.lose.setTransform(this.who.px, this.who.py, 1, 1, 0, 0, 0, 33, 90);
}

//  the main function
Cat.prototype.catGo = function(){
    // The best is an Object of Circle
    var best = this.getBestPosition();
    if (best == -1) {
        victory();
    } else {
        setState(this.who, G.STATE_NORMAL);
        this.who = best;
        setState(this.who, G.STATE_CAT);
        this.reflashCatPosion();
    }
};

Cat.prototype.addCat = function(parents){
    parents.addChild(this.normal);
    parents.addChild(this.lose);
};

// switch the display of cat
Cat.prototype.catIsAngry = function(){
    this.normal.visible = false;
    this.lose.visible = true;
};

Cat.prototype.reflashCatPosion = function(){
    this.lose.setTransform(this.who.px, this.who.py, 1, 1, 0, 0, 0, 33, 90);
    this.normal.setTransform(this.who.px, this.who.py, 1, 1, 0, 0, 0, 33, 90);
};

Cat.prototype.getBestPosition = function(){
    var allConnectCanGo = this.who.getAllConnectCanGo();
    if (allConnectCanGo.length > 0) {
        // The best is an Object of Circle
        var best = allConnectCanGo[0];
        if (this.who.isBoundary()) {
            return best;
        }
        for (var i = 0; i < allConnectCanGo.length; i++) {
            if (allConnectCanGo[i].isBoundary()) {
                best = allConnectCanGo[i];
                break;
            }
            if (best.chooseWay(allConnectCanGo[i])) {
                best = allConnectCanGo[i];
            }
        }
        return best;
    } else {
        return -1;
    }
};
// -- The Core Class Of Cat --------------------------------------------------------------