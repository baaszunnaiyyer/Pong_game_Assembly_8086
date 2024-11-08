STACK SEGMENT PARA STACK
        DB 64 DUP ('  ')
Stack Ends

DATA SEGMENT PARA 'DATA'
    
    WINDOW_WIDTH DW 140h               ; = 320
    WINDOW_HEIGHT DW 0C8h              ; = 200
    WINDOW_BOUNDS DW 6h                ; variable to detect Collisions early 
    
    TIME_AUX DB 0                      ;variable used when checking if the time has changed
    
    BALL_ORIGINAL_X DW 0A0h            ;Origin Of Ball position X
    BALL_ORIGINAL_Y DW 64h             ;Origin Of Ball Position Y
    BALL_X DW 0Ah                      ;Xpos        DW = Define Word stores 16 bits
    BALL_Y DW 0Ah                      ;Ypos        While DB stores 8
    BALL_SIZE DW 05h                   ;size of the ball (how many pixels dose the ball have in width and height)
    BALL_VELOCITY_X DW 05h             ; (Horizontal)Velocity of the ball
    BALL_VELOCITY_Y DW 02h             ; (Vertical) Velocity of the ball
    
    
    PADDLE_L_X DW 0Ah                  ;Current X position of Paddle LEFT
    PADDLE_L_Y DW 0Ah                  ;Current Y position of Paddle LEFT 
    
    PADDLE_R_X DW 130h                 ;Current X position of Paddle Right
    PADDLE_R_Y DW 0Ah                  ;Current Y position of Paddle Right
    
    PADDLE_WIDTH DW 05h                
    PADDLE_HEIGHT DW 1Fh
    
    PADDLE_VELOCITY DW 05h
    
    
    
DATA ENDS

CODE SEGMENT PARA 'CODE'
        MAIN PROC FAR
            ASSUME CS:CODE, DS:DATA, SS:STACK; Assuming
            PUSH DS         ;push to the stacvk te DS Segment
            SUB AX, AX      ;clean AX reg
            PUSH AX         ;push  AX to the stack
            MOV AX, DATA    ;save ont the AX register the contents of the DATA Segment
            MOV DS,AX       ;save on the DS segment the content of AX
            pop AX          ;relese the top item from the stack to the AX Register        
                            ;relese the top item from the stack to the AX Register
                       
                CALL CLEAR_SCREEN
                
                CHECK_TIME :
                
                    MOV AH, 2Ch ;get the system time
                    INT 21h     ;CH = hour CL = Minute DH= second DL = 1/100 seconds
                                
                    CMP DL, TIME_AUX   ;is the current time is equal to the previous one
                    JE CHECK_TIME      ;if its the same, check again
                    
                    ;if it's different, then draw, move, etc.
                    MOV TIME_AUX, DL ;UPDATE TIME
                    
                    
                    
                    
                    CALL CLEAR_SCREEN
                    
                    CALL MOVE_BALL
                                                                          
                    CALL DRAW_BALL
                    
                    CALL MOVE_PADDLES
                    
                    CALL DRAW_PADDLES
                    
                    
                    JMP CHECK_TIME ;after everything check time again
                    
                
                RET

                
         MAIN ENDP
        
                                                                                                                                                                                                            
        
        
        
        
        
         
         MOVE_BALL PROC NEAR
            
            MOV AX,BALL_VELOCITY_X ; move the ball Horizoltaly
            ADD BALL_X, AX         
            
            MOV AX, WINDOW_BOUNDS
            CMP BALL_X, AX        ;BALL_X < 0(Y -> Collided)
            JL RESET_POSITION      
            
            MOV AX,WINDOW_WIDTH
            SUB AX, BALL_SIZE
            SUB AX, WINDOW_BOUNDS
            CMP BALL_X, AX         ;BALL_X > WINDOW_WIDTH - BALL_SIZE (Y -> collided)
            JG RESET_POSITION
            JMP MOVE_BALL_VERICALLY      
            
            RESET_POSITION:
                CALL RESET_BALL_POSITION ;BALL_VELOCITY_X = - BALL_VELOCITY_X
                RET
            
            MOVE_BALL_VERICALLY:
                MOV AX,BALL_VELOCITY_Y ; move the ball Vertically
                ADD BALL_Y, AX
            
            MOV AX, WINDOW_BOUNDS
            CMP BALL_Y, AX        ;BALL_Y < 0(Y -> Collided)
            JL NEG_VELOCITY_Y
            
            MOV AX, WINDOW_HEIGHT
            SUB AX, BALL_SIZE
            SUB AX, WINDOW_BOUNDS
            CMP BALL_Y, AX
            JG NEG_VELOCITY_Y
            
            
            ; Check if the ball is colliding with the right paddle
            ; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2
            ; BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_X + PADDLE_WIDTH 
            ; && PADDLE_WIDTH && BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT
            
            MOV AX, BALL_X
            ADD AX, BALL_SIZE
            CMP AX, PADDLE_R_X
            JNG CHECK_COLLISION_WITH_LEFT_PADDLE
            
            MOV AX, PADDLE_R_X
            ADD AX, PADDLE_WIDTH
            CMP BALL_X, AX
            JNL CHECK_COLLISION_WITH_LEFT_PADDLE
            
            MOV AX, BALL_Y
            ADD AX, BALL_SIZE
            CMP AX, PADDLE_R_Y
            JNG CHECK_COLLISION_WITH_LEFT_PADDLE
            
            MOV AX, PADDLE_R_Y
            ADD AX, PADDLE_HEIGHT
            CMP BALL_Y, AX
            JNL CHECK_COLLISION_WITH_LEFT_PADDLE
            
            ;IF it reaches this point, the point is colliding with the right paddle
            
            JMP NEG_VELOCITY_X
            
            
            ; Check if the ball is colliding with the Left paddle
            CHECK_COLLISION_WITH_LEFT_PADDLE:           
            ; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2
            ; BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_X + PADDLE_WIDTH 
            ; && PADDLE_WIDTH && BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT
            
            MOV AX, BALL_X
            ADD AX, BALL_SIZE
            CMP AX, PADDLE_L_X
            JNG EXIT_COLLISION_CHECK
            
            MOV AX, PADDLE_L_X
            ADD AX, PADDLE_WIDTH
            CMP BALL_X, AX
            JNL EXIT_COLLISION_CHECK
            
            MOV AX, BALL_Y
            ADD AX, BALL_SIZE
            CMP AX, PADDLE_L_Y
            JNG EXIT_COLLISION_CHECK
            
            MOV AX, PADDLE_L_Y
            ADD AX, PADDLE_HEIGHT
            CMP BALL_Y, AX
            JNL EXIT_COLLISION_CHECK
            
            JMP NEG_VELOCITY_X
            

            
            NEG_VELOCITY_Y:
                NEG BALL_VELOCITY_Y
                RET
            
            NEG_VELOCITY_X:
                NEG BALL_VELOCITY_X
                RET
            
            
                
            EXIT_COLLISION_CHECK:
                RET
            
         MOVE_BALL ENDP
         
         
         
         
         
         
         
         
         
         
         
         
         MOVE_PADDLES PROC NEAR
            
            ;left paddle movement
            
            ; check if any key is being pressed (if not Check other paddle)
            MOV AH, 01h
            INT 16h
            
            JZ CHECK_RIGHT_PADDLE_MOVEMENT ; ZF = 1, JZ -> Jump if Zero  ZF = 0 means Some key is pressed
            
            ; check which key is being pressed (AL = ASCII CHARACTER)
            MOV AH, 00h
            INT 16h 
            
                       
            ; if its 'w' or 'W' move up
            CMP AL, 77h ;'w'
            JE MOVE_L_P_U
            
            CMP AL, 57h
            JE MOVE_L_P_U    ;LEFT PADDLE UP
            
            ; if its 's' or 'S' move down
            CMP AL, 73h ;'s'
            JE MOVE_L_P_D            
            CMP AL, 53h ;'S'
            JE MOVE_L_P_D    ;LEFT PADDLE DWON
            JMP CHECK_RIGHT_PADDLE_MOVEMENT
            
            
            MOVE_L_P_U:            
                MOV AX, PADDLE_VELOCITY
                SUB PADDLE_L_Y, AX
                
                MOV AX, WINDOW_BOUNDS
                CMP PADDLE_L_Y, AX
                JL FIX_PADDLE_LEFT_TOP_POSITION
                JMP CHECK_RIGHT_PADDLE_MOVEMENT
                
                
                FIX_PADDLE_LEFT_TOP_POSITION:
                    MOV AX, WINDOW_BOUNDS
                    MOV PADDLE_L_Y, AX
                    JMP CHECK_RIGHT_PADDLE_MOVEMENT
                
                           
            MOVE_L_P_D:            
                MOV AX, PADDLE_VELOCITY
                ADD PADDLE_L_Y, AX
                MOV AX, WINDOW_HEIGHT
                SUB AX, WINDOW_BOUNDS
                SUB AX, PADDLE_HEIGHT
                CMP PADDLE_L_Y, AX
                JG FIX_PADDLE_LEFT_BOTTOM_POSITION
                
                               
                JMP CHECK_RIGHT_PADDLE_MOVEMENT
            
                FIX_PADDLE_LEFT_BOTTOM_POSITION:
                    MOV PADDLE_L_Y, AX
                    JMP CHECK_RIGHT_PADDLE_MOVEMENT
            
            
            ;Right paddle movement
            CHECK_RIGHT_PADDLE_MOVEMENT:
                  ; if its 'i' or 'I' move up
                CMP AL, 69h ;'i'
                JE MOVE_R_P_U
                
                CMP AL, 49h   ;'I'
                JE MOVE_R_P_U    ;LEFT PADDLE UP
                
                ; if its 'k' or 'K' move down
                CMP AL, 6Bh ;'k'
                JE MOVE_R_P_D            
                CMP AL, 4Bh ;'K'
                JE MOVE_R_P_D                       ;LEFT PADDLE DWON
                JMP EXIT_PADDLE_MOVEMENT
           
                
                MOVE_R_P_U:
                    MOV AX, PADDLE_VELOCITY
                    SUB PADDLE_R_Y, AX
                    
                    MOV AX, WINDOW_BOUNDS
                    CMP PADDLE_R_Y, AX
                    JL FIX_PADDLE_RIGHT_TOP_POSITION
                    JMP CHECK_RIGHT_PADDLE_MOVEMENT
                    
                    
                    FIX_PADDLE_RIGHT_TOP_POSITION:
                        MOV AX, WINDOW_BOUNDS
                        MOV PADDLE_R_Y, AX
                        JMP EXIT_PADDLE_MOVEMENT
                
                
                MOVE_R_P_D:
                    MOV AX, PADDLE_VELOCITY
                    ADD PADDLE_R_Y, AX
                    MOV AX, WINDOW_HEIGHT
                    SUB AX, WINDOW_BOUNDS
                    SUB AX, PADDLE_HEIGHT
                    CMP PADDLE_R_Y, AX
                    JG FIX_PADDLE_RIGHT_BOTTOM_POSITION
                    
                                   
                    JMP CHECK_RIGHT_PADDLE_MOVEMENT
                
                    FIX_PADDLE_RIGHT_BOTTOM_POSITION:
                        MOV PADDLE_R_Y, AX
                        JMP EXIT_PADDLE_MOVEMENT
                
            
            EXIT_PADDLE_MOVEMENT:
                RET
                
                
                        
         MOVE_PADDLES ENDP
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         RESET_BALL_POSITION PROC NEAR
            
                
                MOV AX, BALL_ORIGINAL_X
                MOV BALL_X, AX
                
                MOV AX, BALL_ORIGINAL_Y
                MOV BALL_Y, AX
                
                
                
                RET
         RESET_BALL_POSITION ENDP
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         DRAW_BALL PROC NEAR
            
            MOV CX, BALL_X ;Set the intial column (X pos)
            MOV DX, BALL_Y ; Set The initial line (Y Pos)
            
            DRAW_BALL_HORIZONTAL:
                MOV AH, 0Ch ;set the Configuration to write a pixel
                MOV AL, 0Fh ;choose white as color
                MOV BH, 00h ; Set the page Number               
                INT 10h ;Intrupt
                
                INC CX ;CX = CX +1
                MOV AX, CX        ;CX-BALL_X > BALL_SIZE
                SUB AX, BALL_X
                CMP AX, BALL_SIZE
                JNG DRAW_BALL_HORIZONTAL
                
                MOV CX, BALL_X      ;the CS Register Gose back to its initial pos
                INC DX  ; we advance one line
                
                MOV AX,DX ;DX - BALL_Y > BALL_SIZE
                SUB AX, BALL_Y
                CMP AX, BALL_SIZE
                JNG DRAW_BALL_HORIZONTAL  
                
            
                
            
            
            RET
         DRAW_BALL ENDP
         
         
         
         
         
         
         
         DRAW_PADDLES PROC NEAR
              
              MOV CX, PADDLE_L_X
              MOV DX, PADDLE_L_Y
              
              
              DRAW_PADDEL_LEFT_HORIZONTAL:
                 MOV AH, 0Ch ;set the Configuration to write a pixel
                 MOV AL, 0Fh ;choose white as color
                 MOV BH, 00h ; Set the page Number               
                 INT 10h ;Intrupt
              
                 INC CX ;CX = CX +1
                 MOV AX, CX        ;CX-PADDLE_X > PADDLE 
                 SUB AX, PADDLE_L_X                                       
                 CMP AX, PADDLE_WIDTH
                 JNG DRAW_PADDEL_LEFT_HORIZONTAL
                 
                 MOV CX, PADDLE_L_X      ;the CS Register Gose back to its initial pos
                 INC DX  ; we advance one line
                
                 MOV AX,DX ;DX - BALL_Y > BALL_SIZE
                 SUB AX, PADDLE_L_Y
                 CMP AX, PADDLE_HEIGHT
                 JNG DRAW_PADDEL_LEFT_HORIZONTAL
                 
                 
              MOV CX, PADDLE_R_X
              MOV DX, PADDLE_R_Y
              
              
              DRAW_PADDEL_RIGHT_HORIZONTAL:
                 MOV AH, 0Ch ;set the Configuration to write a pixel
                 MOV AL, 0Fh ;choose white as color
                 MOV BH, 00h ; Set the page Number               
                 INT 10h ;Intrupt
              
                 INC CX ;CX = CX +1
                 MOV AX, CX        ;CX-PADDLE_X > PADDLE 
                 SUB AX, PADDLE_R_X                                       
                 CMP AX, PADDLE_WIDTH
                 JNG DRAW_PADDEL_RIGHT_HORIZONTAL
                 
                 MOV CX, PADDLE_R_X      ;the CS Register Gose back to its initial pos
                 INC DX  ; we advance one line
                
                 MOV AX,DX ;DX - BALL_Y > BALL_SIZE
                 SUB AX, PADDLE_R_Y
                 CMP AX, PADDLE_HEIGHT
                 JNG DRAW_PADDEL_RIGHT_HORIZONTAL   
                 
                 
               
         
              RET      
         DRAW_PADDLES ENDP
         
         
         
         
         
         
         
         
         
         
         CLEAR_SCREEN PROC NEAR
                MOV AH, 00h     ;set Video mode 
                MOV AL, 13h     ;Choose the Video mode
                INT 10h         ;ececutes the configuration
                
                MOV AH, 0Bh     ;set the configuration
                MOV BH, 00h     ;to the background color
                MOV BL, 0Fh     ;Chosse black as Background color
                INT 10h         
                
                
                RET
         CLEAR_SCREEN ENDP
         
         
         
         
         
         
         
         
         
         
         
         
CODE ENDS
END

