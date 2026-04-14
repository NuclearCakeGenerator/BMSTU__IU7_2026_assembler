%include "constants.inc"
%include "../chars.inc"
%include "../linux_sys.inc"

global enter_number

segment .data
    prompt db "Enter a 16 bit HEXADECIMAL number: ", CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    PROMPT_LEN equ $ - prompt

segment .text
