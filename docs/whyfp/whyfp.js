/*
function initialPosition(){
    return {
        turn: true,
        board: [
            [ ' ', ' ', ' ' ],
            [ ' ', ' ', ' ' ],
            [ ' ', ' ', ' ' ]
        ]
    };
}
*/

function initPosition(board_str, turn_char){
    let b=[];
    for(let i=0; i<9; ++i)
        b[i]=board_str.charAt(i);
    return {
        board: b,
        turn: turn_char=='O'
    };
}

/*
function stringPosition(board){
    let p=board.pos;
    row1=p[0][0]+'|'+p[0][1]+'|'+p[0][2];
    row2=p[1][0]+'|'+p[1][1]+'|'+p[1][2];
    row3=p[2][0]+'|'+p[2][1]+'|'+p[2][2];
    str='Turn: '+(board.turn? 'O': 'X')+'\n'+
        row1+'\n-+-+-\n'+row2+'\n-+-+-\n'+row3;
    return str;
    }
*/

function getBoardRow(b, y){
    return b[3*y]+'|'+b[3*y+1]+'|'+b[3*y+2];
}

function getBoard(pos){
    b=pos.board;
    return getBoardRow(b, 0)+
        '\n-+-+-\n'+
        getBoardRow(b, 1)+
        '\n-+-+-\n'+
        getBoardRow(b, 2);
}

function getTurn(pos){
    return pos.turn? 'O': 'X';
}

function moves(pos){
    let mark=pos.turn? 'O': 'X';
    let list=[];
    for(let y=0; y<3; ++y){
        for(let x=0; x<3; ++x){
            if(pos.board[3*y+x]==' '){
                let b=[...pos.board];
                b[3*y+x]=mark;
                list.push({
                    board: b,
                    turn: !pos.turn,
                    subst: function(assignment){return this;},
                    isAtom: function(){return true;}
                });
            }
        }
    }
    return list;
}

function check3line(board, mark){ // 縦方向の並び
    let count=0;
    for(let x=0; x<3; ++x){
        if(board[x]==mark &&
           board[x+3]==mark &&
           board[x+6]==mark)
            ++count;
    }
    return count;
}

function check3row(board, mark){ // 横方向の並び
    let count=0;
    for(let y=0; y<3; ++y){
        if(board[3*y]==mark &&
           board[3*y+1]==mark &&
           board[3*y+2]==mark)
            ++count;
    }
    return count;
}

function check2diagonal(board, mark){ // 斜め方向の並び
    let count=0;
    if(board[0]==mark && board[4]==mark && board[8]==mark) ++count;
    if(board[2]==mark && board[4]==mark && board[6]==mark) ++count;
    return count;
}

function static(pos){
    let b=pos.board;
    return check3line(b, 'O')+
        check3row(b, 'O')+
        check2diagonal(b, 'O')-
        check3line(b, 'X')-
        check3row(b, 'X')-
        check2diagonal(b, 'X');
}
