# TicTacToe
AI project for playing tictactoe using minimax algorithm

Human against computer. Pick human marker ( X or O). Can quit game at any time pressing Q.
Can use lower case for all user input and computer understands both lower and upper case
Can use board larger than typical 3x3 used in TictacToe, but minimax takes much longer to run and 
the alpha-beta pruning improvement is required. 

User inputs coordinate using letter digit format (ie a1, b3, etc) while computer invokes minimax algorithm that evaluates all remaining possibilites. 
The tree of options is large in the beginning and that translates into computer taking longer time to evaluate options, but it reduces as board fills up with moves. 

The crux of the algorithm is recursively invoking the minimax function and evaluating remaining options and picking the best move assuming the opponent does the same. 
There is also a stupid_place option for computer used in the development to get the mechanics of the game coded without the ai complexity!

