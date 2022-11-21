import sys
import numpy as np
import random
from time import sleep
import logging
# used https://www.neverstopbuilding.com/blog/minimax for minimax refresher and inspiration very well explained

logger = logging.getLogger()
logger.setLevel(logging.WARNING)

SIZE = 3
PLAYERS = ['X', 'O']
EMPTY = '-'
COMPUTER = ''
COLINDEX = np.array([chr(i) for i in np.arange(SIZE) + ord('A')])   # A,B,C,....
ROWINDEX = np.append([' '], np.arange(1, SIZE + 1)).reshape(SIZE + 1, 1)  # 1,2,3.....


# print the board as 2D array, show, A,B,C for column, 1,2,3 for rows, remove [ ] and '
def show(board):

    b1 = np.vstack((COLINDEX, board))   # add colindex at the top
    b2 = np.hstack((ROWINDEX, b1))      # add rowindex on the left
    print(str(b2).replace(' [', '').replace('[', '').replace(']', '').replace("'", ''))


# Check for empty places on board
def possibilities(board):
    results = []

    for i in range(len(board)):
        for j in range(len(board)):
            if board[i][j] == EMPTY:
                results.append((i, j))
    return results


# Select random mark placement for the player
def stupid_place(board, player):
    selection = possibilities(board)
    current_loc = random.choice(selection)
    board[current_loc] = player
    return board


# evaluate all options and pick the highest score
def smart_place(board, player):
    # we dont need to store an array for best move, best score
    # it is sufficient to keep best_move and best_score and once a better score is found
    # replace best move and score with the recent discovery
    best_move = (None, None)    # initialize best move,
    best_score = -1000          # initialize best score

    for current_move in possibilities(board):
        board[current_move] = player  # set move and calculate score for board using recursive minimax
        current_score = minimax(board, 0, is_maximize=False)     # minimax invoked for next move(opponent) with is a minimizer
        logging.info(f"Move (row, column) => {current_move}, score: {current_score}")
        # current move is AI player, pick highest score, dont bother for being equal to current score,
        # look for strict improvement ( > than rathern than >= )
        if current_score > best_score:
            best_move = current_move
            best_score = current_score
        board[current_move] = EMPTY  # reset move back to try next option without affecting the board

    board[best_move] = player
    return board


# recursively call minimax for all subtree options to compute score
def minimax(board, depth, is_maximize):
    # can be win, loss, draw or continue play
    state = evaluate(board)
    if state == COMPUTER:
        # computer wins, get 10 points and subtract points for needing more moves to win
        return 10 - depth

    opponent = ''.join(PLAYERS).replace(COMPUTER, '')  # find opponent to AI player
    if state == opponent:
        # computer lost, -10 points for me and add points for needing more moves to lose (slow death)
        return depth - 10

    # draw no points
    if state == 'DRAW':
        return 0

    scores, player = [], ""
    for current_move in possibilities(board):
        # when is_maximize is true, player is computer
        player = COMPUTER if is_maximize else opponent

        board[current_move] = player
        # we alternate turns by recursive invocation using "not is_maximize", increase depth by one
        # to keep track of number of moves
        scores.append(minimax(board, depth + 1, not is_maximize))
        board[current_move] = EMPTY  # reset move to evaluate from the initial board as given in function input arg

    logger.info(f'player: {player}, maximize:{is_maximize}, scores:{scores}')
    # pick best move for computer, assume best move (lowest score for computer) for opponent
    return max(scores) if is_maximize else min(scores)


# user inputs coordinates ( ie A1, B2, C3)
def user_place(board, player):
    val = input(f'Player {player} turn: ')
    if val.upper() == 'Q':  # Q aborts game whenever
        abort()

    if len(val) != 2:  # coordinates should be 2 characters only column X row
        print("Position not correct. Try again.")
        user_place(board, player)

    col, row = list(val)
    col = col.upper()
    # check row in 1,2,3.... and col in A,B,C, ....
    if row not in ROWINDEX or col not in COLINDEX:
        print("Position not correct. Try again.")
        user_place(board, player)

    position = (ord(row) - 49, ord(col) - 65)
    if position in possibilities(board):
        board[position] = player
    else:
        print("Position not correct. Try again.")
        user_place(board, player)
    return board


# Checks whether the current player won
# palyer could be one of 'X' or 'O' depending on PLAYERS array entries
def wins(board, player):
    win_configuration = [player] * SIZE  # either 3 X or 3 O depending on chosen AI player

    # check both diagonals first for a win
    if win_configuration in [board.diagonal().tolist(), np.fliplr(board).diagonal().tolist()]:
        return True

    for i in range(len(board)):
        # check horizontal, then vertical
        # [start_row_index: end_row_index, start_column_index: end_column_index]
        if win_configuration in [board[i, :].tolist(), board[:, i].tolist()]:
            return True

    # game not won yet
    return False


# Evaluates whether there is a winner or a tie
# returns 'X' , 'O', 'DRAW', 'CONTINUE'
def evaluate(board):
    # check for win
    for player in PLAYERS:
        if wins(board, player):
            return player

    if np.all(board != EMPTY):
        return 'DRAW'   # check for draw
    else:
        return 'CONTINUE'  # game must continue


# Main function to start the game
def play_game(human):
    # create board and show it
    board = np.full((SIZE, SIZE), EMPTY)
    # test board = np.array([['O', '-', '-'], ['-', '-', '-'], ['X', '-', '-']])
    show(board)
    global COMPUTER
    COMPUTER = ''.join(PLAYERS).replace(human, '')

    while True:
        for player in PLAYERS:
            if player == human:
                # human, request coordinate input
                board = user_place(board, player)
            else:
                # computer plays, replace use smart_place
                # board = stupid_place(board, player)
                board = smart_place(board, player)

            print(f"\t\t\t{player} moves")
            show(board)
            sleep(0.5)

            result = evaluate(board)
            if result in PLAYERS:
                return f'Winner is: {result}'
            if result == 'DRAW':
                return 'No one won'
            # the only other option is "CONTINUE" , which continues playing


def abort():
    print('Aborting game ....')
    sys.exit(1)


if __name__ == "__main__":
    while True:
        option = input("""
Play TicTacToe 
Pick X or O
Q aborts game
>>>""")
        if option.upper() not in ['X', 'O', 'Q']:
            print(f'Incorrect input:{option}. Retry\n')
        else:
            if option.upper() == 'Q':
                abort()
            print(str(play_game(option.upper())))
