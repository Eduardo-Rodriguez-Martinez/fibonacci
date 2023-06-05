; Este programa se ensambla y liga con el siguiente comando:
; ml fibonacci.asm /Fe fibonacci.exe /link /SUBSYSTEM:CONSOLE /DEFAULTLIB:"C:\Irvine\Kernel32.lib"
TITLE Calcula el n-esimo elemento de la secuencia de Fibonnacci	(fibonacci.asm)

.386
.MODEL flat, stdcall
.STACK 4096

; //Win32 Console handles
STD_OUTPUT_HANDLE EQU - 11

GetStdHandle PROTO, ; //get standard handle
    nStdHandle: DWORD; //type of console handle

WriteConsoleA PROTO, ; //write a buffer to the console
    hConsoleOutput: DWORD, ; //output handle
    lpBuffer: PTR BYTE, ; //pointer to buffer
    nNumberOfCharsToWrite: DWORD, ; //size of buffer
    lpNumberOfCharsWritten: PTR DWORD, ; //ptr to number of bytes written
    lpReserved: DWORD; //(not used)

ExitProcess PROTO, ; //exit program
    dwExitCode: DWORD; //return code

.data
    N   EQU 6               ;// Indice del elemento de la secuencia a calcular
    endl     EQU <0dh, 0ah>
    mensaje  BYTE "El elemento X en la secuencia de Fibonnacci es: Y", endl
    longitud DWORD ($ - mensaje)
    manejadorConsola    DWORD 0
    bytesEscritos       DWORD ?
    fib BYTE N + 1 DUP('x')
.code
main PROC
    ;// Llama a la funcion Fibs pasando como parametros el indice del elemento
    ;// de la secuencia a ser calculado y un puntero al arreglo de enteros. Los
    ;// parametros son pasados a traves de la pila
    ;// void Fibs(int N, int *fib)
	lea ebx, fib
	push ebx
	mov eax, N
	push eax
    call Fibs
    pop eax
    pop ebx

    ;// Convierte enteros (int) a su ASCII (char)
    movzx edx, byte ptr[ebx + N]
    add edx, 30h
    mov ebx, OFFSET mensaje
    mov ecx, longitud
    mov [ebx + ecx - 3], dl
    add eax, 30h
    mov [ebx + 12], al

    ;// Obtiene el puntero al manejador estandar de la consola
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov manejadorConsola, eax

    ;// Imprime el mensaje
    INVOKE WriteConsoleA,
        manejadorConsola,
        ADDR mensaje,
        longitud,
        ADDR bytesEscritos,
        0

    ;// Termina el programa principal y devuelve control al SO
    INVOKE ExitProcess, 0
main endp

Fibs PROC
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ;// indice del elemento que queremos calcular
    mov ebx, [ebp+12]   ;// direccion del arreglo
    cmp eax, 1
    jbe T1       ;// si n<= 1 salta a T1
    dec eax
	push ebx
	push eax
    call Fibs           ;// llamada recursiva para f(n-1)
    pop eax
    pop ebx
    dec eax
	push ebx
	push eax
    call Fibs           ;// llamada recursiva para f(n-2)
    pop eax
    pop ebx
    mov eax, [ebp+8]    ;// indice del elemento que queremos calcular
    mov ebx, [ebp+12]   ;// direccion del arreglo
    movzx edx, byte ptr [ebx + eax - 1];// obtiene f(n - 1)
    movzx ecx, byte ptr [ebx + eax - 2];// obtiene f(n - 2)
    add edx, ecx                       ;// f(n-1)+f(n-2)
    mov [ebx + eax], dl ;// guarda f(n)
    jmp finSub
T1:	mov [ebx + eax], al ;// guarda caso base
finSub:     pop ebp
            ret
Fibs endp
end main
