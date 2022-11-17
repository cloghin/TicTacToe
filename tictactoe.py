import numpy as np
import random
from time import sleep
import sys

PLAYERS = ['X', 'O']
EMPTY = '-'


def show(board):
    # remove [ ] and '
    print(str(board).replace(' [', '').replace('[', '').replace(']', '').replace("'",''))


# Check for empty places on board
def possibilities(board):
    results = []

    for i in range(len(board)):
        for j in range(len(board)):

            if board[i][j] == EMPTY:
                results.append((i, j))
    return results


# Select a random place for the player
def random_place(board, player):
    selection = possibilities(board)
    current_loc = random.choice(selection)
    board[current_loc] = player
    return board


# implement
def minimax(board, depth, isMaximizingPlayer):
    if len(possibilities(board)) == 0:
        pass


def smart_place(board, player):
    # TBD implement minimax algorithm
    best = None
    # evaluate all option, give score and pick best
    for current in possibilities(board):
        if current > best:
            best = current

    board[best] = player
    return board


def request_place(board, player):
    val = input(f'Player {player} turn. Enter XY position: (ie 11 in top left 33 in bottom right):')
    position = tuple([int(i) - 1 for i in [*val]])

    if position in possibilities(board):
        board[position] = player
    else:
        print("Position not correct. Try again.")
        request_place(board, player)
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
    winner = 0

    for player in PLAYERS:
        if wins(board, player):
            winner = player

    if np.all(board != EMPTY) and winner == 0:
        winner = -1
    return winner


# Main function to start the game
def play_game(gameconfig):

    # create board and show it
    board = np.full((3, 3), EMPTY)
    show(board)

    winner = 0
    while winner == 0:
        for i, player in enumerate(PLAYERS):
            if gameconfig[i] == 'C':
                # computer plays, replace with smart_place
                board = random_place(board, player)
            else:  # human, request coordinate input
                board = request_place(board, player)
            print(f"Board after {player} move")
            show(board)
            sleep(0.5)

            winner = evaluate(board)
            if winner != 0:
                break
    return winner


if __name__ == "__main__":
    while True:
        option = input("""
Play TicTacToe. Choose a play option. H-Human, C-Computer: HH/HC/CH/CC/Q-quit
>>>""")
        if option.upper() == 'Q':
            sys.exit()
        else:
            if len(option) != 2:
                print(f'Incorrect input:{option}. Retry\n')
            else:

                if option.upper() not in ['HH','HC','CH','CC']:
                    print(f'Incorrect input:{option}. Retry\n')
                else:
                    print("Winner is: " + str(play_game([*option.upper()])))
