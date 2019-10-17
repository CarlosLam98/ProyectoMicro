.MODEL small
.STACK
.DATA
    cabeza DB '***********$'
    row DB 0FEh dup (?)
    col DB 0FEh dup (?)
    var1 DB 'a'
    msgEr DB 'No se permite retroceder$'
    msgEd DB 'Fin del juego$'
    lenght DB 3
    x DB 5
    y DB 5
    auxX DB 0
    auxY DB 0
    auxX1 DB 0
    auxY1 DB 0
    crece DB 0                          ;Bool para ver si debe crecer
    movLeft DB 0                        ;Cuantos movimientos le hacen falta para crecer
.CODE

Programa:
    MOV AX, @DATA
    MOV DS,AX
    ;Creacion de la serpiente principal
    MOV row[0],5
    MOV row[1],5
    MOV row[2],5
    
    MOV col[0],4
    MOV col[1],3
    MOV col[2],2
    
LimpiaPantalla:
    MOV AX, 03H
    INT 10H
    MOV AH, 06h
    MOV AL, 00h
    MOV BH, 12h
    MOV CX, 00h
    MOV DX, 244fH
    INT 10h
    
    CMP crece, 1                        ;Nuestro bool de que la serpiente paso por la fruta
    JNE PantallaIncio
    DEC movLeft
    CMP movLeft, 0                      ;Debemos de validar que haya pasado todo el cuerpo para poder hacerlo crecer
    JNE PantallaIncio

    MOV CL, lenght 
    MOV SI, 0

Aux:                                ;Aux para contar el tama?o del snake, ya que no se puede pasar el valor directo a SI
    INC SI
    LOOP Aux    
    MOV row[SI], 2                  ;Creacion de la nueva parte de la serpiente
    MOV col[SI], 2
    INC lenght                      
    
PantallaIncio:
    XOR CX, CX
    XOR DX, DX
    XOR AX, AX

    MOV DH, 0                       ;Renglon
    MOV DL, 0                       ;Columna
    CALL Interrupcion02                        
    
    MOV AH, 09H                     ;Impresion de la primera cadena
    LEA DX, cabeza
    INT 21h
    
Bordes:
    MOV DH, CL
    MOV DL, 0                       ;Columna
    CALL Interrupcion02
    
    CALL Body
    
    MOV DH, CL                      
    MOV DL, 09H                     ;Columna
    INC DL
    CALL Interrupcion02
    
    CALL Body
    
    INC CL
    CMP CL, 09
    JNE Bordes
    
    MOV DH, CL                      ;Renglon
    MOV DL, 0                       ;Columna
    CALL Interrupcion02                        
    
    MOV AH, 09H                     ;Impresion de cadena
    LEA DX, cabeza
    INT 21h
    ;-----------TERMINA EL AREA DE BORDES---------
    
    ;Imprimir la comida de tu tio
    
    MOV DH, 2
    MOV DL, 2                       ;Columna
    CALL Interrupcion02
    
    MOV AH, 02
    MOV DL, 'F'
    INT 21h
    ;-------Imprimir a tu tio-------
    MOV CL, lenght
    MOV SI, 0
Im:
    MOV DH, row[SI]
    MOV DL, col[SI]                 ;Columna
    CALL Interrupcion02
    
    XOR DX,DX
    CALL Body
    INC SI
    LOOP Im
    
    ;------Imprimir la cabeza de tu tio----
    
    MOV DH, y                       ;Renglon
    MOV DL, x                       ;Columna
    CALL Interrupcion02                        

    ;Lectura de tecla
Lectura:
    MOV ah, 07h                     ;Lectura sin mostrar en pantalla
    INT 21h                         

    CMP AL, 's'
    JZ IncrementoY
    CMP AL, 'a' 
    JZ DecrementoX
    CMP AL, 'w'
    JZ DecrementoY
    CMP AL, 'd'
    JZ IncrementoX
    CMP AL, 'x'                     ;Cuando el usuario presione la tecla x saldra del juego
    JZ Fin1
    JMP LimpiaPantalla              ;En caso de que no seleccione ninguna de las anteriores, volvemos
    
Body:
    MOV AH, 02
    MOV DL, '*'
    INT 21h
    RET
Interrupcion02:
    MOV AH, 02H                     ;Donde se colocara el cursor (Interrupcion)
    MOV BH, 00H                     ;Numero de pagina
    INT 10H  
    RET   
IncrementoX:
    CMP var1, 'd'
    JZ EtError
    CALL Movimiento
    INC x
    CALL LecturaPosicion
    MOV var1, 'a'
    JMP LimpiaPantalla
IncrementoY:
    CMP var1, 'w'
    JZ EtError
    CALL Movimiento    
    INC y
    CALL LecturaPosicion
    MOV var1, 's'
    JMP LimpiaPantalla  
DecrementoX:
    CMP var1, 'a'
    JZ EtError
    CALL Movimiento
    DEC x 
    CALL LecturaPosicion
    MOV var1, 'd'
    JMP LimpiaPantalla
DecrementoY:
    CMP var1, 's'
    JZ EtError
    CALL Movimiento
    DEC y  
    CALL LecturaPosicion
    MOV var1, 'w'
    JMP LimpiaPantalla
    
Fin1:
    JMP Fin
    
EtError:                                ;Mensaje de error
    MOV AX, 03H
    INT 10H
    MOV AH, 06h
    MOV AL, 00h
    MOV BH, 80h
    MOV CX, 00h
    MOV DX, 244fH
    INT 10h
    MOV DX, OFFSET msgEr
    MOV AH, 09H
    INT 21H
    MOV AH, 07H
    INT 21H
    JMP LimpiaPantalla

Movimiento:                         ;Actualizacion del cuerpo de la serpiente, la cabeza es separada
    XOR AL, AL
    MOV AL, x
    MOV auxX, AL
    MOV AL, y
    MOV auxY, AL
    MOV CL, lenght
    MOV SI, 0 
Mover:
    MOV AL, col[SI]
    MOV auxX1, AL
    MOV AL, row[SI]
    MOV auxY1, AL
    
    MOV AL, auxX
    MOV col[SI], AL
    MOV AL, auxY
    MOV row[SI], AL
    
    MOV AL, auxX1
    MOV auxX, AL
    MOV AL, auxY1
    MOV auxY, AL
    INC SI
    LOOP Mover
    RET
    
LecturaPosicion:                    ;Metodo para leer la siguiente posicion a la que ira la serpiente
    XOR DX,DX
    MOV DH, y                       ;Renglon
    MOV DL, x                       ;Columna
    CALL Interrupcion02
    MOV AH, 08H
    MOV BH, 00H                     ;Numero de pagina
    INT 10H
    CMP AL, '*'
    JE Fin                          ;Cuando topa con algun * terminara el juego
    CMP AL, 'F'
    JNE Crecer                      ;En caso de que no sea F saltar el proceso
    XOR AL,AL
    MOV crece, 1
    MOV AL, lenght
    MOV movLeft, AL
    INC movLeft
Crecer:
    RET

    ;-----------------FIN DEL PROGRAMA-------------------------
Fin:
    MOV AX, 03H
    INT 10H
    MOV AH, 06h
    MOV AL, 00h
    MOV BH, 80h
    MOV CX, 00h
    MOV DX, 244fH
    INT 10h
    MOV DX, OFFSET msgEd
    MOV AH, 09H
    INT 21H
    MOV AH, 07H
    INT 21H

    MOV AX, 03H
    INT 10H
    MOV AH,4ch
    INT 21H
    END Programa