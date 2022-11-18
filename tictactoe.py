import sys

import numpy as np
import random
from time import sleep


# used https://www.neverstopbuilding.com/blog/minimax for minimax refresher and inspiration
# very well explained

PLAYERS = ['X', 'O']
EMPTY = '-'
AI = ''


def show(board):
    # show, A,B,C for column, 1,2,3 for rows, remove [ ] and '
    colindex = np.array(['A', 'B', 'C'])
    rowindex = np.array([' ', '1', '2', '3']).reshape(4, 1)
    b1 = np.vstack((colindex, board))
    b2 = np.hstack((rowindex, b1))
    print(str(b2).replace(' [', '').replace('[', '').replace(']', '').replace("'",''))


# Check for empty places on board
def possibilities(board):
    results = []

    for i in range(len(board)):
        for j in range(len(board)):
            if board[i][j] == EMPTY:
                results.append((i, j))
    return results


# Select a random place for the player
def stupid_place(board, player):
    selection = possibilities(board)
    current_loc = random.choice(selection)
    board[current_loc] = player
    return board


# evaluate all options and pick the highest score
def smart_place(board, player):
    best_move = (None, None) # initialize best move
    best_score = -1000  # initialize best score

    for current_move in possibilities(board):
        board[current_move] = player # set move
        current_score = minimax(board, 0, False)
        # print(current_move, current_score)
        if current_score > best_score:
            best_move = current_move
            best_score = current_score
        board[current_move] = EMPTY # reset move

    board[best_move] = player
    return board


# recursively call minimax for all subtree options to compute score
def minimax(board, depth, isMaximize):
    # print(f'{board}, player {player}, depth {depth}, is Maximize {isMaximize}')
    state = evaluate(board)
    if state == AI:
        # i win, i get 10 points and subtract points for needing more moves to win
        return 10 - depth

    opponent = ''.join(PLAYERS).replace(AI, '')
    if state == opponent:
        # i lose, -10 points for me and add points for needing more moves to lose (slow death)
        return depth - 10

    # draw no points
    if state == 'DRAW':
        return 0

    scores = []
    for current_move in possibilities(board):
        if isMaximize:
            board[current_move] = opponent  # move
        else:
            board[current_move] = AI
        scores.append(minimax(board, depth+1, not isMaximize))
        board[current_move] = EMPTY  # reset

    if isMaximize:
        return max(scores)
    else:
        return min(scores)


def user_place(board, player):
    val = input(f'Player {player} turn: ')
    if val.upper() == 'Q':
        abort()

    if len(val) != 2:
        print("Position not correct. Try again.")
        user_place(board, player)

    col, row = list(val)
    col = col.upper()
    if col not in ['A', 'B', 'C'] or row not in ['1','2','3']:
        print("Position not correct. Try again.")
        user_place(board, player)

    position = (ord(row)-49, ord(col) - 65)
    if position in possibilities(board):
        board[position] = player
    else:
        print("Position not correct. Try again.")
        user_place(board, player)
    return board


# Checks whether the current player won
def wins(board, player):
    win_configuration = [player]*3

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
def evaluate(board):
    # check for win
    for player in PLAYERS:
        if wins(board, player):
            return player

    if np.all(board != EMPTY):
        return 'DRAW' # check for draw
    else:
        return 'CONTINUE'  # game must continue


# Main function to start the game
def play_game(human):
    # create board and show it
    #board = np.full((3, 3), EMPTY)
    # board = np.array([['-', '-', '-'], ['-', '-', '-'], ['-', '-', '-']])
    show(board)
    global AI
    AI = ''.join(PLAYERS).replace(human, '')

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
            # the only other option is -1 , which continues playing


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
