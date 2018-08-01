	jmp	main_game
;
;The following are the possible messages that will be shown to the user
;
msg0 	db 	'Welcome to this game!',0
msg00	db	'Hint: Press Alt+Enter to switch to full screen to have a',0
msg01	db	' better gameplay. Press any key to exit during the game.',0

msg10 	db 	'The game has four paddles on the borders of the screen. ',0
msg11	db	'When you move your mouse, the bottom and the right paddle', 0
msg12	db 	' will move along the direction of the mouse, ',0
msg13	db	'but the top and left paddle will move against the direction', 0
msg14	db	' of the mouse. Use the mouse to control the paddles and ', 0
msg15	db	'catch all purple, white and light green balls, avoid all ',0
msg16	db	'black, blue and red balls! If you catch a bad ',0
msg17	db	'ball, you lose a life. In addition, if you catch a '0
msg18	db	'blue ball, the paddle that catches it freezes; if you catch', 0
msg19	db	' a red ball, the paddle that catches it will lose control', 0
msg191	db	'; if you MISS a white ball, the screen will flash. You lose', 0
msg192	db	' a life by missing a purple, white or light green ball. ', 0
msg0200	db	'If your score exceeds an integer multiple of 200, you earn 1',0
msg020	db	' extra life. The game has 9 difficulties:', 0
msg021	db	'         **********Press any key to continue**********',0

msg20 	db 	'Now please choose a difficulty level(1~9), enter 0 to exit:', 0 
msg21	db	'1-extremely easy: normal balls only, extremely slow ball speed',0
msg210	db	', very slow ball shooting rate, long paddle, 1pt per ball',0
msg22	db	'2-very easy: tiny amount of bad balls, slow ball speed',0
msg220	db	', slow ball shooting rate, long paddle, 1pt per ball',0
msg23	db	'3-easy: small amount of bad balls, slow ball speed'
msg230	db	', slow ball shooting rate, long paddle, 1pt per ball',0
msg24	db	'4-normal: small amount of bad balls, moderate ball speed', 0
msg240	db	', moderate ball shooting rate, medium paddle, 2pts per ball',0
msg25	db	'5-hard: moderate amount of bad balls, moderate ball speed', 0
msg250	db	', moderate ball shooting rate, medium paddle, 3pts per ball',0
msg26	db	'6-very hard: moderate amount of bad balls, fast ball speed,', 0
msg260	db	', fast ball shooting rate, medium paddle, 4pts per ball',0
msg27	db	'7-nightmare: moderate amount of bad balls, very fast ball spee', 0
msg270	db	'd, fast ball shooting rate, short paddle, 6pts per ball',0
msg28	db	'8-inferno: large amount of bad balls, very fast ball speed', 0
msg280	db	'fast ball shooting rate, short paddle, 8pts per ball',0
msg29	db	'9-mission impossible: large amount of bad balls, extremely ', 0
msg290	db	'fast ball speed, very fast ball shooting rate, very short ',0
msg291	db	'paddle, 10pts per ball',0
msg3	db	'You lose all your lives. Game over. Your final score is ',0
msg4	db	'Would you like to replay this game?(Enter 1 to play again)', 0
msg5 	db 	'You entered an invalid level, please try again:',0
msg6	db	'====Thank you for trying this game and have a good day!====', 0
;
;The following are the colors 
;(Note for colors: 0-black, 1-dark blue, 2-dark green, 3-blue green, 4-dark red,
;5-dark purple, 6-dark yellow, 7-light grey, 8-dark grey, 9-medium blue, A-light green
;B-light blue, C-light red, D-light purple, E-light yellow, F-white)
;
padc_normal	equ	12h		;paddle is dark green
padc_frozen	equ	1bh		;paddle is light blue 
padc_confused	equ	1ch		;paddle is light red 
fieldc	equ	1eh			;background color is dark blue
ball1c	equ	1dh			;ball (type1) color is light purple
ball2c	equ	1fh			;ball (type2) color is white
ball3c	equ	1ah			;ball (type3) color is light green
ball4c	equ	010h			;ball (type3) color is black
ball5c	equ	01bh			;ball (type4) color is light blue
ball6c	equ	01ch			;ball (type5) color is light red
backc	equ	07h			;color to return back to DOS
;
;Following is the sound
;
sbeep	equ	1000
sdur	equ	5			;frequency and duration for catching a good ball
lbeep	equ	5000
ldur	equ	15			;frequency and duration for catching a bad ball
funr	dw	52, 321, 17, 0
	dw	18, 252, 9, 0
	dw	9, 210, 5, 0
	dw	18, 252, 9, 0
	dw	9, 210, 5, 0		;a short music when game over(HP=0)
	dw	0
;
;Following are varaibles frequently used by the game program
;
difficulty db	?			;The difficulty of the game(1-9), choosen by the user	
delay_time dw	?			;Whenever the function delay is called, the time in delay_time will be delayed. Seconds of delay=delay_time/100
score	dw	0			;The initial score of the player
ball_count db	0			;The number of balls on the screen
ball_countdown db 20			;The timer between creating two balls	
blink_countdown db 10			;The timer that blink lasts	
speed_countdown db 0			;The timer to update ball position
score_count	db 0			;The counter for adding a life	
status_timer equ 255			;The timer for a bad status to last
blink_duration equ 20			;The duration of blink time		
;
;The global state variable that helps trigger events.
;0 means currently no events to trigger
;1 means start screen blinking because a white ball(ball2) is missed
;2 means freeze a paddle
;3 means confuse a paddle
;
global_state	db 0
temp	db	?
;
;The following are the game property variables
;
AIball_counter	db 0			;AIball counter. Additional counter to halven AI ball's speed. Must be zero or 1.
paddle_length db ?			;The length of the paddle(0-3). 0 is length 1, 1 is length 3, 2 is length 5, and 3 is length 7
pad_length db	0			;The "true" length of the paddle computed from paddle_length
max_balls  db	?			;Maximum number of balls that can appear on the game
ball_speed db	?			;Ball speed. Actually it's just the delay time
ball_interval db ?			;Interval time between balls shooting out
bad_pivot  db	?			;The pivot(0-100) of bad and good balls. If a random number x is greater than pivot, then it's a bad ball
white_pivot db	?			;The pivot(0-100) of white balls. If a random number x is greater than pivot, then it's a white ball, otherwise it's yellow ball
score_increment db ?			;The score the user gets when catching a good ball
life	dw	?			;The life of the player
min_pad_X db	0			;minimum paddle X position
max_pad_X db	79			;maximum paddle X position
min_pad_Y db	0			;minimum paddle Y position
max_pad_Y db	24			;maximum paddle X position
;
;This array stores the data for all the paddles. Each paddle occupy 3 bytes. 
;First byte: Paddle status (0 ok, 1 frozen, 2 confusion). 
;Second byte: Bad status time countdown(normally 0. Will be nonzero when in status 1 or 2. Then this byte stores the time remaining to recover to status 0). 
;Third byte: Paddle's position(vertical: paddle_length ~ 24-paddle_length; horizontal: paddle_length ~ 79-paddle_length
;paddles[0] is bottom paddle, paddle[3] is right paddle, paddle[6] is top paddle, paddle[9] is left paddle
;
paddles	db	12 dup(0)
;
;This array stores the data for all the balls(max 12) in the scenerio. Each ball occuy 3 bytes
;First byte: Ball type(0 currently no ball, 1 yellow(normal balls), 2 white(flash balls), 4 black(bomb), 5 blue(freezer), 6 red(confuser)
;Second byte: Ball's x position(0-79)  Third byte: ball's y position(0-24) 
;Fourth byte: Ball's x velocity  Fifth byte: ball's y velocity
;It's guaranteed that no more than max balls will appear on the screen at the same time
;
balls	db	60 dup(0)
;
;This array stores all the AI balls status, each entry si in this array corresponds to the AI ball balls[si]
;(By the way, this array is really a waste of memory, there are much better ways to do the same job, but since memory is inexpensive, I'll use
;this nasty but straightforward approach)
;0: There is currently no AI ball at index si
;1: Current AI ball is moving towards a near-border
;21: Current AI ball is wandering around in left near-border
;22: Current AI ball is wandering around in right near-border
;23: Current AI ball is wandering around in top near-border
;24: Current AI ball is wandering around in bottom near-border
;3: Current AI ball is trying to charge out of a border
;
AIstatus  db	60 dup(0)
;
;This procedure serves as a prelude of the game. The procedure will remind the user how to play the game and allow the user to choose a difficulty before starting the game
;
main_game:
	call	reset_game
	call	init_welcome
	mov	delay_time, 2
	add	life, 5			;I add life by 5 and check if life decrease below 5 later to avoid the situation that 2+ balls exit the border at the
					;same time when life is already 1.
	
maingame_lp:	
	call	update_paddle		;update paddle position, status etc
	call	paint_paddle		;paint the paddles
	call 	create_ball		;create balls(if applicable)		
	call	update_balls		;update positions of the balls
	call	check_collision		;check if any ball collide with a paddle
	call	paint_balls		;paint all the balls	
	cmp	blink_countdown, 0	;check if we need to blink
	je	no_blink
	call	paint_blink		;blink
	dec	blink_countdown		;and decrement blink duration
no_blink:
	call	delay			;slow down the game a little bit
	call	paint_field		;clear the screen with background color		
	cmp	life, 5
	jbe	round_over		;life decrease to zero, round over
	mov	ah, 1
	int	16h
	jnz	game_over	
	jmp	maingame_lp
round_over:
	lea	si, funr
	call	tune
	mov	dx, 0
	mov	cx, 25*80
	mov	bl, backc
	mov	al, ' '
	call	paint
	mov	ax, 4c00h		;reset screen back to normal
	mov	si, offset msg3
	call	print_msg		;print out msg3
	call	print_score		;print out score
	call	new_line
	mov	si, offset msg4
	call	print_msg		;print out msg4
	call	new_line
	mov	ah, 0
	int	16h
	cmp	al, '1'
	je	main_game		;user enter 1. Play game again
game_over:
	mov	dx, 0
	mov	cx, 25*80
	mov	bl, backc
	mov	al, ' '
	call	paint
	mov	ax, 4c00h		;reset screen back to normal
	call	new_line
	mov	si, offset msg6
	call	print_msg		;print out msg6		
	int	20h			;return to DOS

init_welcome	PROC
	push	ax
	push	bx
	push	si	
	mov	si, offset msg0		
	call	print_msg		;print out msg0
	call	new_line
	mov	si, offset msg00	
	call	print_msg		;print out msg00
	mov	si, offset msg01	
	call	print_msg		;print out msg01
	call	new_line
	mov	si, offset msg10		
	call	print_msg		;print out msg10
	mov	si, offset msg11	
	call	print_msg		;print out msg11
	mov	si, offset msg12	
	call	print_msg		;print out msg12
	mov	si, offset msg13	
	call	print_msg		;print out msg13
	mov	si, offset msg14		
	call	print_msg		;print out msg14
	mov	si, offset msg15		
	call	print_msg		;print out msg15	
	mov	si, offset msg16		
	call	print_msg		;print out msg16
	call	new_line	
	mov	si, offset msg17		
	call	print_msg		;print out msg17	
	mov	si, offset msg18		
	call	print_msg		;print out msg18	
	mov	si, offset msg19		
	call	print_msg		;print out msg19
	mov	si, offset msg191		
	call	print_msg		;print out msg191
	mov	si, offset msg192		
	call	print_msg		;print out msg192	
	mov	si, offset msg0200	
	call	print_msg		;print out msg0200	
	mov	si, offset msg020		
	call	print_msg		;print out msg020
	call	new_line
	mov	si, offset msg021	;print out msg021
	call	print_msg
	call	new_line
	mov	ah, 0
	int	16h	
	mov	si, offset msg21	;print out msg21
	call	print_msg
	mov	si, offset msg210	;print out msg210
	call	print_msg
	call	new_line
	mov	si, offset msg22	;print out msg22
	call	print_msg
	mov	si, offset msg220	;print out msg220
	call	print_msg
	call	new_line
	mov	si, offset msg23	;print out msg23
	call	print_msg
	mov	si, offset msg230	;print out msg230
	call	print_msg
	call	new_line
	mov	si, offset msg24	;print out msg24
	call	print_msg
	mov	si, offset msg240	;print out msg240
	call	print_msg
	call	new_line
	mov	si, offset msg25	;print out msg25
	call	print_msg
	mov	si, offset msg250	;print out msg250
	call	print_msg
	call	new_line
	mov	si, offset msg26	;print out msg26
	call	print_msg
	mov	si, offset msg260	;print out msg260
	call	print_msg
	call	new_line
	mov	si, offset msg27	;print out msg27
	call	print_msg
	mov	si, offset msg270	;print out msg270
	call	print_msg
	call	new_line
	mov	si, offset msg28	;print out msg28
	call	print_msg
	mov	si, offset msg280	;print out msg280
	call	print_msg
	call	new_line
	mov	si, offset msg29	;print out msg29
	call	print_msg
	mov	si, offset msg290	;print out msg290
	call	print_msg
	mov	si, offset msg291	;print out msg291
	call	print_msg
	call	new_line
	mov	si, offset msg20
	call	print_msg		;print out msg20
	call	new_line
	mov	ah, 0
input_difficulty_lp:	
	int	16h			;get user input difficulty
	cmp	al, '0'
	jb	invalid_difficulty	
	cmp	al, '9'
	ja	invalid_difficulty	;check if the user input is valid
	sub	al, '0'	
	cmp	al, 0
	je	input_game_over		
	mov	difficulty, al		;Store the difficulty in "difficulty"	
	jmp	input_difficulty_lpout
invalid_difficulty:
	mov	si, offset msg5
	call	print_msg		;print out msg5
	call	new_line
	jmp	input_difficulty_lp	;user input is invalid. Prompt the user to input again	
input_game_over:
	jmp	game_over
input_difficulty_lpout:
	call	game_setup
	mov	delay_time, 60
	call	delay			;delay some time to let the user get ready
	pop	si
	pop	bx
	pop	ax
	ret			
init_welcome	ENDP
;
;This procedure reset the game
;
reset_game	PROC
	mov	cx, 0
	mov	ax, 0
	mov	bx, 0
	mov	dx, 0
	mov	si, 0
	mov	di, 0	
	mov	score, 0
	mov	ball_count, 0
	mov	ball_countdown, 20
	mov	blink_countdown, 10
	mov	speed_countdown, 0
	mov	score_count, 0
	mov	global_state, 0
	mov	AIball_counter, 0
	mov	min_pad_X, 0
	mov	min_pad_Y, 0
	mov	max_pad_X, 79
	mov	max_pad_Y, 24
	mov	pad_length, 0
	mov	paddle_length, 0
	mov	si, 0
clear_lp1:
	cmp	si, 11
	ja	clear_lp1out
	mov	paddles[si], 0
	inc	si
	jmp	clear_lp1
clear_lp1out:
	mov	si, 0
clear_lp2:
	cmp	si, 59
	ja	clear_lp2out
	mov	balls[si], 0
	inc	si
	jmp	clear_lp2
clear_lp2out:
	mov	si, 0
clear_lp3:
	cmp	si, 59
	ja	clear_lp3out
	mov	AIstatus[si], 0
	inc	si
	jmp	clear_lp3
clear_lp3out:
	mov	si, 0
reset_game	ENDP
;
;This procedure will set up all the game property variables depending on difficulty
;
game_setup	PROC
	push	ax
	cmp	difficulty, 1
	jne	difficulty2_setup
	mov	max_balls, 4
	mov	paddle_length, 3
	mov	ball_speed, 40
	mov	ball_interval, 150
	mov	bad_pivot, 100
	mov	white_pivot, 100
	mov	score_increment, 1
	mov	life, 20
	jmp	finish_game_setup
difficulty2_setup:
	cmp	difficulty, 2
	jne	difficulty3_setup
	mov	max_balls, 5
	mov	paddle_length, 3
	mov	ball_speed, 30
	mov	ball_interval, 100
	mov	bad_pivot, 90
	mov	white_pivot, 90
	mov	score_increment, 1
	mov	life, 14	
	jmp	finish_game_setup
difficulty3_setup:
	cmp	difficulty, 3
	jne	difficulty4_setup
	mov	max_balls, 6
	mov	paddle_length, 3
	mov	ball_speed, 30
	mov	ball_interval, 100
	mov	bad_pivot, 75
	mov	white_pivot, 75
	mov	score_increment, 1
	mov	life, 12
	jmp	finish_game_setup
difficulty4_setup:
	cmp	difficulty, 4
	jne	difficulty5_setup
	mov	max_balls, 7
	mov	paddle_length, 2
	mov	ball_speed, 23
	mov	ball_interval, 60
	mov	bad_pivot, 75
	mov	white_pivot, 75
	mov	score_increment, 2
	mov	life, 10
	jmp	finish_game_setup	
difficulty5_setup:
	cmp	difficulty, 5
	jne	difficulty6_setup
	mov	max_balls, 8
	mov	paddle_length, 2
	mov	ball_speed, 21
	mov	ball_interval, 52
	mov	bad_pivot, 60
	mov	white_pivot, 60
	mov	score_increment, 3
	mov	life, 10
	jmp	finish_game_setup	
difficulty6_setup:
	cmp	difficulty, 6
	jne	difficulty7_setup
	mov	max_balls, 9
	mov	paddle_length, 2
	mov	ball_speed, 18
	mov	ball_interval, 30
	mov	bad_pivot, 60
	mov	white_pivot, 60
	mov	score_increment, 4
	mov	life, 10
	jmp	finish_game_setup	
difficulty7_setup:
	cmp	difficulty, 7
	jne	difficulty8_setup
	mov	max_balls, 10
	mov	paddle_length, 1
	mov	ball_speed, 13
	mov	ball_interval, 30
	mov	bad_pivot, 60
	mov	white_pivot, 60
	mov	score_increment, 6
	mov	life, 10
	jmp	finish_game_setup	
difficulty8_setup:
	cmp	difficulty, 8
	jne	difficulty9_setup
	mov	max_balls, 11
	mov	paddle_length, 1
	mov	ball_speed, 13
	mov	ball_interval, 30
	mov	bad_pivot, 40
	mov	white_pivot, 40
	mov	score_increment, 8
	mov	life, 10
	jmp	finish_game_setup	
difficulty9_setup:	
	mov	max_balls, 12
	mov	paddle_length, 0
	mov	ball_speed, 8
	mov	ball_interval, 18
	mov	bad_pivot, 40
	mov	white_pivot, 40
	mov	life, 10
	mov	score_increment, 10
finish_game_setup:
	mov	al, paddle_length		
	add	min_pad_X, al
	add	min_pad_Y, al
	sub	max_pad_X, al
	sub	max_pad_Y, al		;set up the corresponding minX and maxX
	add	al, al
	add	pad_length, al
	add	pad_length, 1		;set up the pad_length from paddle_length		
	pop	ax
	ret
game_setup	ENDP
;
;This procedure updates paddles' positions
;
update_paddle	PROC
	push	si
	push	ax
	push	bx
	push	cx
	push	dx
	mov	si, 0	
	inc	si
	cmp	paddles[si], 0		;check if paddle1's bad-status countdown has reached zero or not
	je	paddle1_status_recovered	;if so, go to change the status back
	dec	paddles[si]		;otherwise decrement the countdown and keep current bad status
	dec	si
	jmp	check_paddle_1
paddle1_status_recovered:
	dec	si
	mov	paddles[si], 0		;change the status back to 0(normal)
			
;check paddle 1, the bottom paddle that moves with the mouse
check_paddle_1:							
	cmp	paddles[si], 1		;check if current paddle is frozen
	je	init_check_paddle_2	;if so, no need to update it's position	
	cmp	paddles[si], 2		;check if current paddle is in confusion
	jne	update_paddle_1
	inc	si
	inc	si
	mov	ax, 79			;random number 0-79
	int	62h
	mov	paddles[si], al		;put this number to the paddle's position
	mov	cl, al
	jmp	check_paddle1_minmax	
update_paddle_1:
	call	mouse_pos
	inc	si
	inc	si			;get si to the index of the array that stores the paddle position		
	mov	paddles[si], cl		;store current horizontal position
check_paddle1_minmax:
	cmp	cl, min_pad_X
	jb	min_pad_1
	cmp	cl, max_pad_X
	ja	max_pad_1		;check if current position exceeds boundary
	jmp	start_check_paddle_2
min_pad_1:		
	mov	bl, min_pad_X		
	mov	paddles[si], bl
	jmp	start_check_paddle_2
max_pad_1:
	mov	bl, max_pad_X
	mov	paddles[si], bl
	jmp	start_check_paddle_2

init_check_paddle_2:
	inc	si
	inc	si			;adjust si to point to one index less than paddle 2
;check paddle 2, the right paddle that moves with the mouse
start_check_paddle_2:
	inc	si			;get si to the current paddle	
	inc	si
	cmp	paddles[si], 0		;check if paddle2's bad-status countdown has reached zero or not
	je	paddle2_status_recovered	;if so, go to change the status back
	dec	paddles[si]		;otherwise decrement the countdown and keep current bad status
	dec	si
	jmp	check_paddle_2
paddle2_status_recovered:
	dec	si
	mov	paddles[si], 0		;change the status back to 0(normal)

check_paddle_2:								
	cmp	paddles[si], 1		;check if current paddle is frozen
	je	init_check_paddle_3	;if so, no need to update it's position		
	cmp	paddles[si], 2		;check if current paddle is in confusion
	jne	update_paddle_2
	inc	si
	inc	si
	mov	ax, 24			;random number 0-24
	int	62h
	mov	paddles[si], al		;put this number to the paddle's position
	mov	dl, al
	jmp	check_paddle2_minmax	
update_paddle_2:
	call	mouse_pos
	inc	si
	inc	si			;get si to the index of the array that stores the paddle position		
	mov	paddles[si], dl		;store current vertical position
check_paddle2_minmax:
	cmp	dl, min_pad_Y
	jb	min_pad_2
	cmp	dl, max_pad_Y
	ja	max_pad_2		;check if current position exceeds boundary
	jmp	start_check_paddle_3
min_pad_2:		
	mov	bl, min_pad_Y		
	mov	paddles[si], bl
	jmp	start_check_paddle_3
max_pad_2:
	mov	bl, max_pad_Y
	mov	paddles[si], bl
	jmp	start_check_paddle_3

init_check_paddle_3:
	inc	si
	inc	si			;adjust si to point to one index less than paddle 3
;check paddle 3, the top paddle that moves against the mouse
start_check_paddle_3:
	inc	si			;get si to the current paddle	
	inc	si
	cmp	paddles[si], 0		;check if paddle3's bad-status countdown has reached zero or not
	je	paddle3_status_recovered	;if so, go to change the status back
	dec	paddles[si]		;otherwise decrement the countdown and keep current bad status
	dec	si
	jmp	check_paddle_3
paddle3_status_recovered:
	dec	si
	mov	paddles[si], 0		;change the status back to 0(normal)

check_paddle_3:					
	cmp	paddles[si], 1		;check if current paddle is frozen
	je	init_check_paddle_4	;if so, no need to update it's position	
	cmp	paddles[si], 2		;check if current paddle is in confusion
	jne	update_paddle_3
	inc	si
	inc	si
	mov	ax, 79			;random number 0-79
	int	62h
	mov	paddles[si], al		;put this number to the paddle's position
	mov	bl, al
	jmp	check_paddle3_minmax
update_paddle_3:
	call	mouse_pos
	inc	si
	inc	si			;get si to the index of the array that stores the paddle position		
	mov	bx, 79
	sub	bx, cx
	mov	paddles[si], bl		;store current horizontal position	
check_paddle3_minmax:
	cmp	bl, min_pad_X
	jb	min_pad_3
	cmp	bl, max_pad_X
	ja	max_pad_3		;check if current position exceeds boundary
	jmp	start_check_paddle_4
min_pad_3:	
	mov	bl, min_pad_X			
	mov	paddles[si], bl
	jmp	start_check_paddle_4
max_pad_3:
	mov	bl, max_pad_X
	mov	paddles[si], bl
	jmp	start_check_paddle_4

init_check_paddle_4:
	inc	si
	inc	si			;adjust si to point to one index less than paddle 4
;check paddle 4, the right paddle that moves with the mouse
start_check_paddle_4:
	inc	si			;get si to the current paddle	
	inc	si
	cmp	paddles[si], 0		;check if paddle4's bad-status countdown has reached zero or not
	je	paddle4_status_recovered	;if so, go to change the status back
	dec	paddles[si]		;otherwise decrement the countdown and keep current bad status
	dec	si
	jmp	check_paddle_4
paddle4_status_recovered:
	dec	si
	mov	paddles[si], 0		;change the status back to 0(normal)

check_paddle_4:			
	cmp	paddles[si], 1		;check if current paddle is frozen
	je	finish_check_paddle	;if so, no need to update it's position	
	cmp	paddles[si], 2		;check if current paddle is in confusion
	jne	update_paddle_4
	inc	si
	inc	si
	mov	ax, 24			;random number 0-24
	int	62h
	mov	paddles[si], al		;put this number to the paddle's position
	mov	bl, al
	jmp	check_paddle4_minmax
update_paddle_4:
	call	mouse_pos
	inc	si
	inc	si			;get si to the index of the array that stores the paddle position		
	mov	bx, 24
	sub	bx, dx
	mov	paddles[si], bl		;store current vertical position
check_paddle4_minmax:
	cmp	bl, min_pad_Y
	jb	min_pad_4
	cmp	bl, max_pad_Y
	ja	max_pad_4		;check if current position exceeds boundary
	jmp	finish_check_paddle
min_pad_4:	
	mov	bl, min_pad_Y			
	mov	paddles[si], bl
	jmp	finish_check_paddle
max_pad_4:
	mov	bl, max_pad_Y
	mov	paddles[si], bl
finish_check_paddle:	
	pop	dx
	pop	cx
	pop	bx
	pop	ax	
	pop	si
	ret	
update_paddle	ENDP
;
;This procedure gets the mouse's position
;
mouse_pos	PROC
	push	ax
	push	bx
	mov	ax, 3
	int	33h
	shr	cx, 1
	shr	cx, 1
	shr	cx, 1			;get the mouse's horizontal position
	shr	dx, 1
	shr	dx, 1
	shr	dx, 1			;get the mouse's vertical position
	pop	bx
	pop	ax
	ret
mouse_pos	ENDP
;
;This procedure creates a ball
;
create_ball	PROC
	push	ax
	push	si
	cmp	ball_countdown, 0
	je	dont_decrement_counter	;check if the timer has reached zero.
	dec	ball_countdown		;decrease ball interval counter
	jmp	finish_create_ball
dont_decrement_counter: 
	mov	al, max_balls
	cmp	ball_count, al
	jae	create_ball_temp1	;check if currently there's less than max_balls number of balls on the screen
	call	emptyball_index		;find an empty entry in balls to put a ball in
	mov	al, ball_interval
	mov	ball_countdown, al	;get a new countdown
	add	ball_count, 1		;add one to ball count	
	mov	ax, 100			
	int	62h		
	cmp	al, bad_pivot		;use a random number to determine if this round creates a bad ball
	ja	create_badball
	mov	ax, 100
	int	62h			;use a random number to determine if this round creates a white ball
	cmp	al, white_pivot
	ja	create_white_or_green_ball
	mov	balls[si], 1
	call	ball_physics		;determine ball attributes(position and velocity)
create_ball_temp1:
	jmp	finish_create_ball
create_white_or_green_ball:
	mov	ax, 100
	int	62h
	cmp	al, 50			;50% chance of either a white ball or lightgreen ball
	ja	create_green_ball	
	mov	balls[si], 2		;a white ball
	call	ball_physics		;determine ball attributes(position and velocity)
	jmp	finish_create_ball
create_green_ball:
	mov	balls[si], 3		;a light green ball
	call	ball_physics		;determine ball attributes(position and velocity)
	mov	AIstatus[si], 1		;set the status to charging to a near-border
	jmp	finish_create_ball
create_badball:
	mov	ax, 100
	int	62h			;use a random number to determine the type of bad ball
	cmp	al, 33
	ja	not_black_ball
	mov	balls[si], 4		;a bomb ball
	call	ball_physics		;determine ball attributes(position and velocity)
	jmp	finish_create_ball
not_black_ball:
	cmp	ax, 66
	ja	red_ball
	mov	balls[si], 5		;a freezing ball
	call	ball_physics		;determine ball attributes(position and velocity)
	jmp	finish_create_ball
red_ball:
	mov	balls[si], 6		;a confusing ball
	call	ball_physics		;determine ball attributes(position and velocity)
	jmp	finish_create_ball
	
finish_create_ball:
	pop	si
	pop	ax
	ret
create_ball	ENDP
;
;This procedure determine a blank index in balls to put a ball in. This value is stored in si	
;
emptyball_index	PROC
	mov	si, 0
emptyball_index_lp:
	cmp	balls[si], 0
	je	emptyball_index_lpout
	add	si, 5
	jmp	emptyball_index_lp
emptyball_index_lpout:
	ret
emptyball_index	ENDP
;
;This procedure determine a random position to launch a ball and a random acceleration
;
ball_physics	PROC
	push	ax
	push	di
	mov	ax, 64
	int	62h
	add	al, 8			;a random x position between 8 and 71
	inc	si
	mov	balls[si], al		;store this number
	mov	ax, 9
	int	62h
	add	al, 8			;a random y position between 8 and 16
	inc	si
	mov	balls[si], al		;store this number
ball_physics_lp:
	mov	ax, 3
	int	62h
	dec	al			;a random x velocity -1, 0 or 1
	inc	si
	mov	balls[si], al		;store this number
	mov	ax, 3
	int	62h
	dec	al			;a random y velocity -1, 0 or 1
	inc	si
	mov	balls[si], al		;store this number
	cmp	al, 0
	jne	ball_physics_lpout
	mov	di, si
	dec	di
	cmp	balls[si], 0
	jne	ball_physics_lpout	;make sure x and y velocity are not both zero
	dec	si
	dec	si			;restore si and try creating different numbers
	jmp	ball_physics_lp
ball_physics_lpout:
	pop	di	
	pop	ax
	ret
ball_physics	ENDP
;
;This procedure updates the positions of the balls. Deletes the ball if it goes out of
;border. If it's a good ball that goes out, decrement life. If life is zero, directly
;jump out of this procedure
;
update_balls	PROC
	push	si
	push	ax
	cmp	speed_countdown, 0
	ja	decrement_speed_counter
	mov	al, ball_speed
	mov	speed_countdown, al
	mov	si, 0
update_ball_lp:
	cmp	si, 59
	jae	update_ball_lpout	;check if end of the array balls
	cmp	balls[si], 0		;check if there is a ball
	je	ignore_ball_update
	call	check_outofborder	;check if current ball is out of border.
	cmp	life, 0
	jbe	update_ball_lpout	;life is zero. Game over	
	cmp	balls[si], 0		;check again if there is a ball(might be deleted by calling the procedure above)
	je	ignore_ball_update
	cmp	balls[si], 3		;check if it's an AI ball
	jne	update_ball_now		;not an AI ball
	cmp	AIball_counter, 0
	jne	ignore_ball_update
	call	handle_AIball		;handle this AI ball
	add	si, 5			;get the index to next ball
	jmp	update_ball_lp			
update_ball_now:
	add	si, 3
	mov	al, balls[si]		;x velocity
	sub	si, 2
	add	balls[si], al		;update x position
	add	si, 3
	mov	al, balls[si]		;y velocity
	sub	si, 2
	add	balls[si], al		;update y position
	add	si, 3			;go to next ball
	jmp	update_ball_lp
ignore_ball_update:
	add	si, 5			;go to next ball
	jmp	update_ball_lp
decrement_speed_counter:
	dec	speed_countdown
update_ball_lpout:
	cmp	AIball_counter, 0
	je	increment_AIcounter
	dec	AIball_counter
	jmp	finish_update_ball
increment_AIcounter:
	mov	AIball_counter, 1
finish_update_ball:
	pop	ax
	pop	si
	ret
update_balls	ENDP
;
;This procedure deals with AI status 1
;
AIstatus1	PROC
	push	ax
	push	di	
	mov	di, si			;first set the index back to the start of this ball
	inc	di
	mov	al, balls[di]		;store x position in al
	inc	di
	mov	ah, balls[di]		;store y position in ah
	inc	di			;then get it to the x velocity position
	
	cmp	al, 4			;check if at the left near border
	jae	handle_AI_status1_2
	mov	AIstatus[si], 21	;At left near-border. Change AI status and velocity
	mov	balls[di], 0
	inc	di
	mov	balls[di], 1		;set velocity to be downward	
	jmp	finish_handle_status1
handle_AI_status1_2:
	cmp	al, 75			;check if at the right near border
	jbe	handle_AI_status1_3
	mov	AIstatus[si], 22	;At right near-border. Change AI status and velocity
	mov	balls[di], 0
	inc	di
	mov	balls[di], -1		;set velocity to be upward	
	jmp	finish_handle_status1
handle_AI_status1_3:
	cmp	ah, 4			;check if at the top near border
	jae	handle_AI_status1_4
	mov	AIstatus[si], 23	;At top near-border. Change AI status and velocity
	mov	balls[di], -1
	inc	di
	mov	balls[di], 0		;set velocity to be left	
	jmp	finish_handle_status1
handle_AI_status1_4:
	cmp	ah, 20			;check if at the bottom near border
	jbe	handle_AI_status1_null
	mov	AIstatus[si], 24	;At bottom near-border. Change AI status and velocity
	mov	balls[di], 1
	inc	di
	mov	balls[di], 0		;set velocity to be right	
	jmp	finish_handle_status1	
handle_AI_status1_null:			;if none apply, simply advance this ball
	call	advance_AIballs	
finish_handle_status1:
	pop	di
	pop	ax
	ret
AIstatus1	ENDP
;
;This procedure deals with AI status 21
;
AIstatus21	PROC
	push	di
	mov	di, si
	add	di, 2
	mov	al, balls[di]		;store ball's y in al	
	mov	di, 11 
	mov	ah, paddles[di]		;store left paddle's y in ah	
	call	abs_ax
	cmp	al, 12
	ja	status21_gotostatus3	;if the absolute distance is big, suddenly change to status 3
	mov	di, si
	add	di, 2
	mov	al, balls[di]		;store this ball's y in al
	add	di, 2			;get di to y velocity
	cmp	al, 2
	jae	status21_checkother	;check if border reached
	mov	balls[di], 1		;change direction
	jmp	status21_finish
status21_checkother:
	cmp	al, 22
	jbe	status21_finish
	mov	balls[di], -1		;change direction
status21_finish:
	call	advance_AIballs
	jmp	finish_handle_AIstatus21
status21_gotostatus3:
	mov	AIstatus[si], 3		;change status and velocity
	mov	di, si
	add	di, 3
	mov	balls[di], -1
	inc	di
	mov	balls[di], 0		;change the velocity to be left
finish_handle_AIstatus21:
	pop	di
	ret
AIstatus21	ENDP
;
;This procedure deals with AI status 22
;
AIstatus22	PROC
	push	di
	mov	di, si
	add	di, 2
	mov	al, balls[di]		;store ball's y in al	
	mov	di, 5
	mov	ah, paddles[di]		;store right paddle's y in ah	
	call	abs_ax
	cmp	al, 12
	ja	status22_gotostatus3	;if the absolute distance is big, suddenly change to status 3
	mov	di, si
	add	di, 2
	mov	al, balls[di]		;store this ball's y in al
	add	di, 2			;get di to y velocity
	cmp	al, 2
	jae	status22_checkother	;check if border reached
	mov	balls[di], 1		;change direction
	jmp	status22_finish
status22_checkother:
	cmp	al, 22
	jbe	status21_finish
	mov	balls[di], -1		;change direction
status22_finish:
	call	advance_AIballs
	jmp	finish_handle_AIstatus22
status22_gotostatus3:
	mov	AIstatus[si], 3		;change status and velocity
	mov	di, si
	add	di, 3
	mov	balls[di], 1
	inc	di
	mov	balls[di], 0		;change the velocity to be right
finish_handle_AIstatus22:
	pop	di
	ret
AIstatus22	ENDP
;
;This procedure deals with AI status 23
;
AIstatus23	PROC
	push	di
	mov	di, si
	inc	di
	mov	al, balls[di]		;store ball's x in al	
	mov	di, 8
	mov	ah, paddles[di]		;store top paddle's x in ah	
	call	abs_ax
	cmp	al, 40
	ja	status23_gotostatus3	;if the absolute distance is big, suddenly change to status 3
	mov	di, si
	inc	di
	mov	al, balls[di]		;store this ball's x in al
	add	di, 2			;get di to x velocity
	cmp	al, 2
	jae	status23_checkother	;check if border reached
	mov	balls[di], 1		;change direction
	jmp	status23_finish
status23_checkother:
	cmp	al, 77
	jbe	status23_finish
	mov	balls[di], -1		;change direction
status23_finish:
	call	advance_AIballs
	jmp	finish_handle_AIstatus23
status23_gotostatus3:
	mov	AIstatus[si], 3		;change status and velocity
	mov	di, si
	add	di, 3
	mov	balls[di], 0
	inc	di
	mov	balls[di], -1		;change the velocity to be up
finish_handle_AIstatus23:
	pop	di
	ret
AIstatus23	ENDP
;
;This procedure deals with AI status 24
;
AIstatus24	PROC
	push	di
	mov	di, si
	inc	di
	mov	al, balls[di]		;store ball's x in al	
	mov	di, 2
	mov	ah, paddles[di]		;store bottom paddle's x in ah	
	call	abs_ax
	cmp	al, 40
	ja	status24_gotostatus3	;if the absolute distance is big, suddenly change to status 3
	mov	di, si
	inc	di
	mov	al, balls[di]		;store this ball's x in al
	add	di, 2			;get di to x velocity
	cmp	al, 2
	jae	status24_checkother	;check if border reached
	mov	balls[di], 1		;change direction
	jmp	status24_finish
status24_checkother:
	cmp	al, 77
	jbe	status24_finish
	mov	balls[di], -1		;change direction
status24_finish:
	call	advance_AIballs
	jmp	finish_handle_AIstatus24
status24_gotostatus3:
	mov	AIstatus[si], 3		;change status and velocity
	mov	di, si
	add	di, 3
	mov	balls[di], 0
	inc	di
	mov	balls[di], 1		;change the velocity to be down
finish_handle_AIstatus24:
	pop	di
	ret
AIstatus24	ENDP
;
;This procedure deals with AI balls indexed at si.
;
handle_AIball	PROC
	push	di
	push	ax
	mov	di, si
				
	inc	di
	mov	al, balls[di]		;store the AI ball's x in al
	inc	di
	mov	ah, balls[di]		;store the AI ball's y in ah
	cmp	AIstatus[si], 1
	je	handle_AI_status1	;handle status 1
	cmp	AIstatus[si], 21
	je	handle_AI_status21	;handle status 21
	cmp	AIstatus[si], 22
	je	handle_AI_status22	;handle status 22
	cmp	AIstatus[si], 23
	je	handle_AI_status23	;handle status 23
	cmp	AIstatus[si], 24
	je	handle_AI_status24	;handle status 24
	cmp	AIstatus[si], 3
	je	handle_AI_Status3	;handle status 3
;	jmp	finish_handle_AIball
handle_AI_status1:
	call	AIstatus1
	jmp	finish_handle_AIball

handle_AI_status21:			;handle left near-border
	call	AIstatus21
	jmp	finish_handle_AIball

handle_AI_status22:			;handle right near-border
	call	AIstatus22
	jmp	finish_handle_AIball

handle_AI_status23:			;handle top near-border
	call	AIstatus23
	jmp	finish_handle_AIball

handle_AI_status24:			;handle bottom near-border
	call	AIstatus24
	jmp	finish_handle_AIball

handle_AI_status3:
	call	advance_AIballs		;simply continue this ball's action, and we are done

finish_handle_AIball:
	pop	ax
	pop	di
	ret	
handle_AIball	ENDP
;
;This procedure advances the AI ball at index si according to its velocity
;
advance_AIballs	PROC
	push	di
	push	ax
	mov	di, si
	add	di, 3
	mov	al, balls[di]		;get the ball's x velocity
	inc	di
	mov	ah, balls[di]		;get the ball's y velocity
	sub	di, 3			;get index to x position
	add	balls[di], al		;change x position	
	inc	di			;get index to y position	
	add	balls[di], ah		;change y position		
	pop	ax
	pop	di
	ret
advance_AIballs	ENDP
;
;This procedure checks if the ball balls[si] will be out of border. Delete it if so
;and reduce life by 1 if it's a good ball
;
check_outofborder	PROC
	push	di
	mov	di, si
	inc	di			;check x
	cmp	balls[di], 0
	jbe	out_of_border	;out of left border
	cmp	balls[di], 79
	jae	out_of_border		;out of right border
	inc	di			;check y
	cmp	balls[di], 0		
	jbe	out_of_border		;out of top border
	cmp	balls[di], 24
	jae	out_of_border		;out of bottom border
	jmp	check_outofborder_finish	;this ball hasn't go out of border yet
	call	leftpad_collide
	jmp	out_of_border
out_of_border:
	cmp	balls[si], 3
	ja	dont_decrement_life
	dec	life			;a good ball missed. Decrease life
	cmp	balls[si], 2
	jne	dont_decrement_life	
	mov	al, blink_duration
	cmp	blink_countdown, 0
	jne	dont_decrement_life	;if already blinking, don't stack with a new blink
	mov	blink_countdown, al	;a white ball missed. Start blinking.
dont_decrement_life:
	mov	AIstatus[si], 0		;clear the status as well
	mov	balls[si], 0		;delete current ball
	dec	ball_count		;decrease total number of balls on screen
check_outofborder_finish:
	pop	di
	ret
check_outofborder	ENDP
;
;This procedure checks collisions of balls with paddles and trigger related events
;
check_collision		PROC
	push	si
	push	ax
	mov	si, 0
check_collision_lp:
	cmp	si, 59
	jae	check_collision_lpout	;check if all array traversed
	cmp	balls[si], 0		
	je	check_next_ball		;check if current position has a ball in it
	inc	si
	mov	al, balls[si]		;store current ball's x in al
	inc	si
	mov	ah, balls[si]		;store current ball's y in ah
	sub	si, 2			;restore si back to the first index of current ball
	cmp	al, 0			;check if possibly collide with left paddle
	jne	check_collision2
	call	leftpad_collide		;check if collide with left paddle
	jmp	check_next_ball
check_collision2:
	cmp	ah, 0			;check if possibly collide with top paddle	
	jne	check_collision3
	call	toppad_collide		;check if collide with top paddle
	jmp	check_next_ball
check_collision3:	
	cmp	al, 79			;check if possibly collide with right paddle
	jne	check_collision4
	call	rightpad_collide
	jmp	check_next_ball		;check if collide with right paddle
check_collision4:
	cmp	ah, 24			;check if possibly collide with bottom paddle
	jne	check_next_ball
	call	bottompad_collide	;check if collide with bottom paddle
check_next_ball:	
	add	si, 5			;go to next ball
	jmp	check_collision_lp	
check_collision_lpout:
	pop	ax
	pop	si
	ret
check_collision		ENDP
;
;This procedure subtracts the values in ah from the value al and store the absolute
;value in al
;
abs_ax	PROC
	cmp	al, ah
	ja	otherwayround
	sub	ah, al
	mov	al, ah
	jmp	end_abs_ax
otherwayround:
	sub	al, ah
end_abs_ax:
	ret
abs_ax	ENDP
;
;This procedure adds score
;
add_score	PROC
	push	ax
	mov	al, score_increment
	mov	ah, 0
	add	score, ax
	add	score_count, al		;also add score to the counter
	cmp	score_count, 200
	jbe	finish_add_score
	inc	life			;scored up to 200 now. Add a life
	mov	score_count, 0		;and restore the counter
finish_add_score:
	pop	ax
	ret
add_Score	ENDP
;
;This procedure assumes a collision occurs with ball indexed at si and one of 
;the four paddles. It handles the corresponding event depending on what type of ball
;collides with a paddle
;
check_collide_type	PROC
	push	ax
	push	dx
	cmp	balls[si], 3
	ja	check_collide_bad_ball
	call	add_score	;A good ball(ball1, 2 or 3) catched. Add the score.
	mov	ax, sbeep
	mov	dx, sdur
	call	note		;good ball caught, play sound
	jmp	no_collide	
check_collide_bad_ball:		;A bad ball is caught
	dec	life			;A bad ball is caught, reduce life
	mov	ax, lbeep
	mov	dx, ldur
	call	note		;bad ball caught, play sound
	cmp	balls[si], 4
	jne	check_collide_ball5	
	dec	life			
	jmp	no_collide
check_collide_ball5:
	cmp	balls[si], 5
	jne	check_collide_ball6
	mov	global_state, 2		;A freezer is caught, change the state value
	jmp	no_collide
check_collide_ball6:
	mov	global_state, 3		;A confuser is caught, change the state value
no_collide:
	mov	AIstatus[si], 0		;clear AI status
	mov	balls[si], 0		;delete this ball
	dec	ball_count		;reduce ball count
	pop	dx	
	pop	ax
	ret
check_collide_type	ENDP
;
;This procedure assumes that a ball indexed at si is in the left border. 
;The procedure checks if the ball collides with the left paddle, and if so, it takes
;corresponding actions, and delete the current ball
;
leftpad_collide	PROC
	push	di
	push	ax
	mov	di, si
	add	di, 2
	mov	al, balls[di]		;store ball's y value in al
	mov	di, 11
	mov	ah, paddles[di]		;store paddle's y value in ah
	call	abs_ax			;get the absolute difference |al-ah|, stored in al
	cmp	al, paddle_length
	ja	finish_leftpad_collide	;current ball doesn't collide with left paddle
;otherwise current ball collides with paddle. Trigger a bunch of events.
	call	check_collide_type	;see what type of collide occur
	mov	al, status_timer	;store the timer in al
	sub	di, 2
	cmp	paddles[di], 0
	jne	finish_leftpad_collide	;if already in a bad status, don't stack this one.
	cmp	global_state, 2
	jne	check_leftpad_state_confuse			
	mov	paddles[di], 1		;this paddle should be frozen
	inc	di
	mov	paddles[di], al
	mov	global_state, 0		;restore the state
	jmp	finish_leftpad_collide
check_leftpad_state_confuse:
	dec	di			;restore the index
	cmp	global_state, 3
	jne	finish_leftpad_collide
	mov	paddles[di], 2		;this paddle should be confused
	inc	di
	mov	global_state, 0		;restore the state
	mov	paddles[di], al
finish_leftpad_collide:
	pop	ax 
	pop	di	
	ret
leftpad_collide	ENDP
;
;This procedure assumes that a ball indexed at si is in the top border. 
;The procedure checks if the ball collides with the top paddle, and if so, it takes
;corresponding actions, and delete the current ball
;
toppad_collide	PROC
	push	di
	push	ax
	mov	di, si
	inc	di
	mov	al, balls[di]		;store ball's x value in al
	mov	di, 8
	mov	ah, paddles[di]		;store paddle's x value in ah
	call	abs_ax			;get the absolute difference |al-ah|, stored in al
	cmp	al, paddle_length
	ja	finish_toppad_collide	;current ball doesn't collide with top paddle
;otherwise current ball collides with paddle. Trigger a bunch of events.
	call	check_collide_type	;see what type of collide occur
	mov	al, status_timer	;store the timer in al
	sub	di, 2
	cmp	paddles[di], 0
	jne	finish_toppad_collide	;if already in a bad status, don't stack this one.
	cmp	global_state, 2
	jne	check_toppad_state_confuse			
	mov	paddles[di], 1		;this paddle should be frozen
	inc	di
	mov	paddles[di], al
	mov	global_state, 0		;restore the state
	jmp	finish_toppad_collide
check_toppad_state_confuse:		
	cmp	global_state, 3
	jne	finish_toppad_collide
	mov	paddles[di], 2		;this paddle should be confused
	inc	di
	mov	global_state, 0		;restore the state
	mov	paddles[di], al
finish_toppad_collide:
	pop	ax 
	pop	di	
	ret
toppad_collide	ENDP
;
;This procedure assumes that a ball indexed at si is in the right border. 
;The procedure checks if the ball collides with the right paddle, and if so, it takes
;corresponding actions, and delete the current ball
;
rightpad_collide	PROC
	push	di
	push	ax
	mov	di, si
	add	di, 2
	mov	al, balls[di]		;store ball's y value in al
	mov	di, 5
	mov	ah, paddles[di]		;store paddle's y value in ah
	call	abs_ax			;get the absolute difference |al-ah|, stored in al
	cmp	al, paddle_length
	ja	finish_rightpad_collide	;current ball doesn't collide with right paddle
;otherwise current ball collides with paddle. Trigger a bunch of events.
	call	check_collide_type	;see what type of collide occur
	mov	al, status_timer	;store the timer in al
	sub	di, 2
	cmp	paddles[di], 0
	jne	finish_rightpad_collide	;if already in a bad status, don't stack this one.
	cmp	global_state, 2
	jne	check_rightpad_state_confuse			
	mov	paddles[di], 1		;this paddle should be frozen
	inc	di
	mov	paddles[di], al
	mov	global_state, 0		;restore the state
	jmp	finish_rightpad_collide
check_rightpad_state_confuse:
	dec	di			;restore the index
	cmp	global_state, 3
	jne	finish_rightpad_collide
	mov	paddles[di], 2		;this paddle should be confused
	inc	di
	mov	global_state, 0		;restore the state
	mov	paddles[di], al
finish_rightpad_collide:
	pop	ax 
	pop	di	
	ret
rightpad_collide	ENDP
;
;This procedure assumes that a ball indexed at si is in the bottom border. 
;The procedure checks if the ball collides with the bottom paddle, and if so, it takes
;corresponding actions, and delete the current ball
;
bottompad_collide	PROC
	push	di
	push	ax
	mov	di, si
	inc	di
	mov	al, balls[di]		;store ball's x value in al
	mov	di, 2
	mov	ah, paddles[di]		;store paddle's x value in ah
	call	abs_ax			;get the absolute difference |al-ah|, stored in al
	cmp	al, paddle_length
	ja	finish_bottompad_collide	;current ball doesn't collide with bottom paddle
;otherwise current ball collides with paddle. Trigger a bunch of events.
	call	check_collide_type	;see what type of collide occur
	mov	al, status_timer	;store the timer in al
	sub	di, 2
	cmp	paddles[di], 0
	jne	finish_bottompad_collide	;if already in a bad status, don't stack this one.
	cmp	global_state, 2
	jne	check_bottompad_state_confuse			
	mov	paddles[di], 1		;this paddle should be frozen
	inc	di
	mov	paddles[di], al
	mov	global_state, 0		;restore the state
	jmp	finish_toppad_collide
check_bottompad_state_confuse:		
	cmp	global_state, 3
	jne	finish_bottompad_collide
	mov	paddles[di], 2		;this paddle should be confused
	inc	di
	mov	global_state, 0		;restore the state
	mov	paddles[di], al
finish_bottompad_collide:
	pop	ax 
	pop	di	
	ret
bottompad_collide	ENDP

;
;This procedure paints the backgournd color
;
paint_field	PROC
	push	ax
	push	bx
	push	cx
	push	dx	
	mov	dx, 0
	mov	cx, 25*80
	mov	bl, fieldc
	mov	al, ' '
	call	paint
;	mov	bl, textc
	call	utext
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
paint_field	ENDP	
;
;This procedure paints the entire screen white to allow blinking
;
paint_blink	PROC
	push	ax
	push	bx
	push	cx
	push	dx	
	mov	dx, 0
	mov	cx, 25*80
	mov	bl, ball2c
	mov	al, 0dbh
	call	paint
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
paint_blink	ENDP	
;
;This procedure paints the paddles position
;
paint_paddle	PROC
	push	ax
	push	bx
	push	dx
	push	cx
	push	si
	mov	si, 6
	mov	dx, 0		
	mov	al, 0dbh		;ready to paint the color of the paddles
	mov	ch, 0
;paint the top paddle
	call	paddle_color		;choose the correct color for paddle
	inc	si
	inc	si			
	mov	dl, paddles[si]	
	sub	dl, paddle_length	;get the top paddle's start position
	mov	cl, pad_length
	dec	cl
	call	paint			;paint paddle

;paint the bottom paddle
	mov	si, 0
	call	paddle_color		;choose the correct color for paddle
	inc	si
	inc	si
	mov	dh, 24			;first set the start position to be the last row	
	mov	dl, paddles[si]		;get the bottom paddle's start position
	sub	dl, paddle_length					
	mov	cl, pad_length
	dec	cl
	call 	paint			;paint paddle

;paint the left paddle
	mov	cx, 1	
	mov	si, 9	
	call	paddle_color		;choose the correct color for paddle
	inc	si
	inc	si
	mov	dh, paddles[si]
	dec	dh		
	sub	dh, paddle_length	;get the left paddle's start position
	mov	ah, pad_length
	mov	dl, 0	
paint_left_pad_lp:
	cmp	ah, 1
	jbe	finish_paint_left_pad
	dec	ah
	inc	dh
	call	paint
	jmp	paint_left_pad_lp
finish_paint_left_pad:	

;paint the right paddle
	mov	ah, 0
	mov	si, 3
	call	paddle_color		;choose the correct color for paddle
	inc	si
	inc	si
	mov	dh, paddles[si]
	dec	dh		
	sub	dh, paddle_length	;get the right paddle's start position
	mov	ah, pad_length	
	mov	dl, 79
paint_right_pad_lp:
	cmp	ah, 1
	jbe	finish_paint_right_pad
	dec	ah
	inc	dh
	call	paint
	jmp	paint_right_pad_lp
finish_paint_right_pad:
	pop	si
	pop	cx
	pop	dx
	pop	bx
	pop	ax
	ret
paint_paddle	ENDP
;
;This procedure chooses the paddle's color according to its status
;
paddle_color	PROC
	cmp	paddles[si], 0
	jne	check_paddle_frozen
	mov	bl, padc_normal
	jmp	finish_paddle_color
check_paddle_frozen:
	cmp	paddles[si], 1
	jne	check_paddle_confused
	mov	bl, padc_frozen
	jmp	finish_paddle_color
check_paddle_confused:
	mov	bl, padc_confused
finish_paddle_color:	
	ret
paddle_color	ENDP
;
;This procedure paints all the balls
;
paint_balls	PROC
	push	ax
	push	bx
	push	si	
	push	dx
	push	cx
	mov	si, 0			;si will be the index for the array balls
	mov	cl, 1			;only draw one ball, not consecutively many!
	mov	al, 0dbh
paint_balls_lp:	
	cmp	si, 59			;check if the entire array traversed
	jae	paint_balls_lpout
	cmp	balls[si], 0		;check if current si position has a ball
	je	ignore_ball		
	call	ball_color		;choose the appropriate color
	inc	si
	mov	dl, balls[si]
	inc	si
	mov	dh, balls[si]		;store ball coordinates
	call	paint			;paint the ball
	inc	si
	inc	si
	inc	si			;get the index to next ball
	jmp	paint_balls_lp
ignore_ball:
	add	si, 5			;go to check next position
	jmp	paint_balls_lp
paint_balls_lpout:
	pop	cx
	pop	dx 
	pop	si	
	pop	bx
	pop	ax
paint_balls	ENDP
;
;This procedure chooses the correct ball color according to balls[si] and store it in bl
;
ball_color	PROC
	cmp	balls[si], 1
	jne	check_ballc2
	mov	bl, ball1c
	mov	al, 1
	jmp	finish_checkball
check_ballc2:
	cmp	balls[si], 2
	jne	check_ballc3
	mov	bl, ball2c
	mov	al, 2
	jmp	finish_checkball
check_ballc3:
	cmp	balls[si], 3
	jne	check_ballc4
	mov	bl, ball3c
	mov	al, 3
	jmp	finish_checkball
check_ballc4:
	cmp	balls[si], 4
	jne	check_ballc5
	mov	bl, ball4c
	mov	al, 5
	jmp	finish_checkball
check_ballc5:
	cmp	balls[si], 5
	jne	check_ballc6
	mov	bl, ball5c
	mov	al, 15
	jmp	finish_checkball
check_ballc6:
	mov	bl, ball6c
	mov	al, 4
finish_checkball:
	ret
ball_color	ENDP

;
;  Routine to update text messages (ball count and score)
;
utext		PROC
      PUSH  AX          ; save registers
      PUSH  DX
;
;  Output score
;
      MOV   DX,0204H         ; set position for score
      CALL  SETPOS
      MOV   AL,'S'           ; set message SCORE:
      CALL  WCHAR
	
      MOV   AL,'C'
      CALL  WCHAR
	
      MOV   AL,'O'
      CALL  WCHAR
	
      MOV   AL,'R'
      CALL  WCHAR
	
      MOV   AL,'E'
      CALL  WCHAR
	
      MOV   AL,':'
      CALL  WCHAR
	
      MOV   AL,' '
      CALL  WCHAR
	
      MOV   AX,score         ; output score
      CALL  UTXTI
;
;  Output difficulty
;
      MOV   DL,32          ; set position for ball count
      CALL  SETPOS
      MOV   AL,'L'         ; set message BALL:
      CALL  WCHAR
	
      MOV   AL,'E'
      CALL  WCHAR
	
      MOV   AL,'V'
      CALL  WCHAR
	
      MOV   AL,'E'
      CALL  WCHAR
	
      MOV   AL,'L'
      CALL  WCHAR
	
      MOV   AL,':'
      CALL  WCHAR

	MOV   AL,' '
      CALL  WCHAR

	mov	al, difficulty
	add	al, '0'
	call	wchar
;
;  Output ball count
;
      MOV   DL,64          ; set position for ball count
      CALL  SETPOS
      MOV   AL,'L'         ; set message BALL:
      CALL  WCHAR
	
      MOV   AL,'I'
      CALL  WCHAR
	
      MOV   AL,'F'
      CALL  WCHAR
	
      MOV   AL,'E'
      CALL  WCHAR
	
      MOV   AL,':'
      CALL  WCHAR
	
      MOV   AL,' '
      CALL  WCHAR
	
;
;  Complete output of ball count
;
     
      MOV   AX,life	   ; get ball count
	cmp	ax, 5
	jae	life_non_trivial	;check if life decrease to a negative number
	mov	ax, 5
life_non_trivial:
	sub	ax, 5
      CALL  UTXTI          ; write ball count
      POP   DX             ; restore registers
      POP   AX
      RET               ; return to caller
utext		ENDP
;
;  Routine to output integer value from AX
;
UTXTI    PROC
      PUSH  CX             ; save registers
      PUSH  DX
      MOV   CX,10          ; divide input argument by 10
      SUB   DX,DX
      DIV   CX
;
;  We have the number / 10 in AX, and number mod 10 in DX. If the
;  value in AX is non-zero, we make a recursive call to output it
;
      OR    AX,AX          ; test non-zero quotient
      JZ    UTX2           ; jump if zero
      CALL  UTXTI          ; else output upper digits
;
;  Here we output the remainder from the division as the last digit
;
UTX2: MOV   AL,DL          ; remainder to AL
      OR    AL,'0'         ; convert to ASCII
      CALL  WCHAR          ; write last digit
      POP   DX             ; restore registers
      POP   CX
      RET                  ; return to caller
UTXTI      ENDP
;
;  Routine to write one character to screen
;
;      (AL)               Character to write
;      CALL  WCHAR
;
WCHAR      PROC
            
      PUSH  BX
	
      PUSH  BP
      SUB   BH,BH          ; set page zero
      MOV   AH,14           ; set code for write teletype
      mov   bl,0e0h
     
      INT   10H            ; write character
      POP   BP             ; restore registers
	
      POP   BX
     
      RET                  ; return to caller
WCHAR      ENDP
;
;This procedure start the text output in a new line
;
new_line	PROC
	push	ax
	push	bx
	mov	ah, 0eh
	mov	bh, 0
	mov	al, 0ah
	int	10h
	mov	al, 0dh
	int	10h
	pop	bx
	pop	ax
	ret
new_line	ENDP
;
;This procedure prints out messages that starts at current value in si
;
print_msg 	PROC
	push	ax
	push	bx
	mov	ah, 0eh
	mov	bh, 0
print_msg_lp:
	mov	al, byte ptr 0h[si]
	cmp	al, 0
	je	print_msg_lpout
	int	10h
	inc	si
	jmp	print_msg_lp
print_msg_lpout:
	pop	bx
	pop	ax
	ret	
print_msg	ENDP
;
;Print out the final score in "score"
;
print_score	PROC
        push    ax
        push    bx
        push    cx
	push	dx
        mov     ah, 0eh
        mov     bh, 0
        mov     cx, score	                ;store decimal in cx

        mov     dx, 0                 
;prints the 10000th digit
        mov     al, '0'                         ;initialize the printed out digit to be 0
print10000thlp:
        cmp     cx, 10000                       ;check if decimal is greater than 10000
        jb      print10000thlpout               ;if not, go to the next part of this procedur
        sub     cx, 10000
        inc     al
        jmp     print10000thlp                  ;otherwise decrement cx by 10000 and increment the 10000th digit by 1
print10000thlpout:
        cmp     al, '0'
        je      print1000th                     ;if al is still 0, ignore it(don't print it out beacuse it's a leading zero)
        mov     dx, 1                 		;otherwise set leadingzeros to 1, indicatiing that whenever a 0 is to be print out, don't ignore it
        int     10h                             ;print out digit
;The following checks if decimal is greater than 1000 and possibly print out the 1000th digit
print1000th:
        mov     al, '0'
print1000thlp:
        cmp     cx, 1000
        jb      print1000thlpout
        sub     cx, 1000
        inc     al
        jmp     print1000thlp
print1000thlpout:
        cmp     dx, 0                 		;dx is not zero, then no matter what al is, print it out
        jne     print1000thlpout2      
        cmp     al, '0'                         ;otherwise check if al is 0
        je      print100th                      ;if it is, ignore it
        mov     dx, 1
print1000thlpout2:
        int     10h
;The following checks if decimal is greater than 100 and possibly print out the 100th digit
print100th:
        mov     al, '0'
print100thlp:
        cmp     cx, 100
        jb      print100thlpout
        sub     cx, 100
        inc     al
        jmp     print100thlp
print100thlpout:
        cmp     dx, 0
        jne     print100thlpout2
        cmp     al, '0'
        je      print10th
        mov     dx, 1
print100thlpout2:        
        int     10h
;The following checks if decimal is greater than 10 and possibly print out the 10th digit
print10th:
        mov     al, '0'
print10thlp:
        cmp     cx, 10
        jb      print10thlpout
        sub     cx, 10
        inc     al
        jmp     print10thlp
print10thlpout:
        cmp     dx, 0
        jne     print10thlpout2
        cmp     al, '0'
        je      print1th
        mov     dx, 1
print10thlpout2:
        int     10h
;The following prints out the number in cx, which is guaranteed to be a single digit
print1th:
        mov     al, '0'
        add     al, cl
        int     10h
	pop	dx
        pop     cx
        pop     bx
        pop     ax
        ret
print_score	ENDP
;
;This procedure will make a time delay. The length of time delayed is stored in the variable "delay_time"
;This function is from the class sample Dewar Game  
;
delay      	PROC
    	PUSH  AX             		
    	PUSH  DX
    	MOV   DH,25         		 
    	MOV   DL,0   
	CALL  SETPOS        
      	SUB   AX,AX          
      	MOV   DX,delay_time 
	call  NOTE		                 
   	POP   DX             
   	POP   AX
   	RET                  
delay     	 ENDP
;
;  Routine to play note on speaker
;
;      (AX)           Frequency in Hz (32 - 32000)
;      (DX)           Duration in units of 1/100 second
;      CALL  NOTE
;
;  Note: a frequency of zero, means rest (silence) for the indicated
;  time, allowing this routine to be used simply as a timing delay.
;
;  Definitions for timer gate control
;
CTRL      EQU   61H           ; timer gate control port
TIMR      EQU   00000001B     ; bit to turn timer on
SPKR      EQU   00000010B     ; bit to turn speaker on
;
;  Definitions of input/output ports to access timer chip
;
TCTL      EQU   043H          ; port for timer control
TCTR      EQU   042H          ; port for timer count values
;
;  Definitions of timer control values (to send to control port)
;
TSQW      EQU   10110110B     ; timer 2, 2 bytes, sq wave, binary
LATCH     EQU   10000000B     ; latch timer 2
;
;  Define 32 bit value used to set timer frequency
;
FRHI      EQU   0012H          ; timer frequency high (1193180 / 256)
FRLO      EQU   34DCH          ; timer low (1193180 mod 256)
;
NOTE      PROC
      PUSH  AX          ; save registers
      PUSH  BX
      PUSH  CX
      PUSH  DX
      PUSH  SI
      MOV   BX,AX          ; save frequency in BX
      MOV   CX,DX          ; save duration in CX
;
;  We handle the rest (silence) case by using an arbitrary frequency to
;  program the clock so that the normal approach for getting the right
;  delay functions, but we will leave the speaker off in this case.
;
      MOV   SI,BX          ; copy frequency to BX
      OR    BX,BX          ; test zero frequency (rest)
      JNZ   NOT1           ; jump if not
      MOV   BX,256         ; else reset to arbitrary non-zero
;
;  Initialize timer and set desired frequency
;
NOT1: MOV   AL,TSQW          ; set timer 2 in square wave mode
      OUT   TCTL,AL
      MOV   DX,FRHI          ; set DX:AX = 1193180 decimal
      MOV   AX,FRLO          ;      = clock frequency
      DIV   BX               ; divide by desired frequency
      OUT   TCTR,AL          ; output low order of divisor
      MOV   AL,AH            ; output high order of divisor
      OUT   TCTR,AL
;
;  Turn the timer on, and also the speaker (unless frequency 0 = rest)
;
      IN    AL,CTRL          ; read current contents of control port
      OR    AL,TIMR          ; turn timer on
      OR    SI,SI            ; test zero frequency
      JZ    NOT2             ; skip if so (leave speaker off)
      OR    AL,SPKR          ; else turn speaker on as well
;
;  Compute number of clock cycles required at this frequency
;
NOT2: OUT   CTRL,AL          ; rewrite control port
      XCHG  AX,BX            ; frequency to AX
      MUL   CX               ; frequency times secs/100 to DX:AX
      MOV   CX,100           ; divide by 100 to get number of beats
      DIV   CX
      SHL   AX,1             ; times 2 because two clocks/beat
      XCHG  AX,CX            ; count of clock cycles to CX
;
;  Loop through clock cycles
;
NOT3:      CALL  RCTR          ; read initial count
;
;  Loop to wait for clock count to get reset. The count goes from the
;  value we set down to 0, and then is reset back to the set value
;
NOT4: MOV   DX,AX          ; save previous count in DX
      CALL  RCTR           ; read count again
      CMP   AX,DX          ; compare new count : old count
      JB    NOT4           ; loop if new count is lower
      LOOP  NOT3           ; else reset, count down cycles
;
;  Wait is complete, so turn off clock and return
;
      IN    AL,CTRL           ; read current contents of port
      AND   AL,0FFH-TIMR-SPKR ; reset timer/speaker control bits
; note that the above statement is an equation
      OUT   CTRL,AL           ; rewrite control port
      POP   SI                ; restore registers
      POP   DX
      POP   CX
      POP   BX
      POP   AX
      RET               ; return to caller
NOTE      ENDP
;
;  Routine to play tune on speaker
;
;      (SI)               Pointer to tune list
;      CALL TUNE
;
;  The tune list is a series of word pairs. The first word is the
;  duration in units of 1/100th of a second, and the second word
;  is the frequency. An entry with zero duration ends the tune list
;  and a zero frequency is a rest (period of silence).
;
TUNE      PROC
      PUSH  AX          ; save registers
      PUSH  DX
;
;  Loop through notes of the tune
;
TUN1: LODSW                ; load duration
      OR    AX,AX          ; test zero duration ending the list
      JZ    TUN2           ; if so, end of tune
;
;  Play next note
;
      XCHG  AX,DX          ; put duration in DX
      LODSW                ; load frequency
      CALL  NOTE           ; play the note
      JMP   TUN1           ; and loop back
;
;  Here at end of tune
;
TUN2: POP   DX             ; restore registers
      POP   AX
      RET                  ; return to caller
TUNE      ENDP
;
;  Routine to read count, returns current timer 2 count in AX
;
RCTR      PROC
      MOV   AL,LATCH         ; latch the counter
      OUT   TCTL,AL          ; latch counter
      IN    AL,TCTR          ; read lsb of count
      MOV   AH,AL
      IN    AL,TCTR          ; read msb of count
      XCHG  AH,AL            ; count is in AX
      RET                    ; return to caller
RCTR      ENDP
;
;Routine to set cursor position(source code: class example)
;     
SETPOS      PROC
      PUSH  AX            ; save registers
      PUSH  BX
      MOV   BH,0          ; set cursor
      MOV   AH,2
      INT   10H
      POP   BX            ; restore registers
      POP   AX
      RET                 ; return to caller
SETPOS      ENDP
;
;  Routine to paint characters on screen(source code: class example)
;
paint      PROC
      PUSH  AX            ; save registers
      PUSH  BX
      CMP   CX,0          ; skip if no chars to paint
      JE    PAINT1
      CALL  SETPOS        ; set cursor position
      MOV   BH,0          ; write the characters
      MOV   AH,9
      INT   10H
;
;  Here with characters painted
;
PAINT1: POP   BX          ; restore registers
      POP   AX
      RET                 ; return to caller
paint      ENDP
	end

