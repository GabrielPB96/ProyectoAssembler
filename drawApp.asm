format PE GUI 4.0
entry start

include 'win32w.inc'

idCirculo equ 1000
idCuadrado equ 1001
idTriangulo equ 1002
idClear equ 1003
idClose equ 1004

xV equ 200
yV equ 100
wV equ 500
hV equ 400

section '.data' data readable writeable
  lapiz PAINTSTRUCT
  panel RECT 15,15,480,300
  rect RECT 220,120,280,180

 ;BOTONES
  typeBoton TCHAR 'BUTTON',0
  labelCirculo TCHAR 'Circle',0
  labelCuadrado TCHAR 'Square',0
  labelTriangulo TCHAR 'Triangle',0
  labelClear TCHAR 'Clear',0
  labelClose TCHAR 'Exit',0

  _error TCHAR 'Startup failed.',0

  number dd 0

  hMsg MSG

 ; VENTANA
  title TCHAR 'FRAME',0
  nameFrame TCHAR 'Frame',0
  wc WNDCLASS 0,WindProc,0,0,NULL,NULL,NULL,COLOR_MENU,NULL,nameFrame

  hdc rd 1
  hPen rd 1
  hPenOld rd 1
  ulb LOGBRUSH
  uhBrush	rd    1
  hBrushOld	rd    1

section '.text' code readable executable

  start:
    invoke GetModuleHandle,0
    mov [wc.hInstance], eax
    invoke LoadIcon,0,IDI_APPLICATION
    mov [wc.hIcon], eax
    invoke LoadCursor,0,IDC_ARROW
    mov [wc.hCursor],eax
    invoke RegisterClass,wc
    test eax, eax
    jz error

    invoke CreateWindowEx,0,nameFrame,title,WS_VISIBLE+WS_DLGFRAME+WS_SYSMENU,\
			  xV,yV,wV,hV,NULL,NULL,[wc.hInstance],NULL
    test eax,eax
    jz error

    invoke GetClientRect,[wc.hInstance],rect

   msg_loop:
	invoke	GetMessage,hMsg,NULL,0,0
	cmp	eax,1
	jb	end_loop
	jne	msg_loop
	invoke	TranslateMessage,hMsg
	invoke	DispatchMessage,hMsg
	jmp	msg_loop

  error:
    invoke  MessageBox,NULL,_error,NULL,MB_ICONERROR+MB_OK
  end_loop:
    invoke  ExitProcess,0

proc WindProc hwnd, msg, wParam, lParam
  cmp [msg],WM_DESTROY
  je .wmdestroy
  cmp [msg], WM_PAINT
  je .paint
  cmp [msg], WM_CREATE
  je .wcreate
  cmp [msg], WM_COMMAND
  je .wcommand
  cmp [msg], WM_KEYDOWN
  je .capturarTecla
  cmp [msg], WM_CLOSE
  je .wclose

  .defwndproc:
    invoke  DefWindowProc,[hwnd],[msg],[wParam],[lParam]
    jmp .finish

  .wcreate:
    stdcall CrearBotones,[hwnd]
    jmp .finish

  .wcommand:
    cmp [wParam], idCirculo
    je .drawCirculo
    cmp [wParam], idCuadrado
    je .drawCuadrado
    cmp [wParam], idTriangulo
    je .drawTriangulo
     cmp [wParam], idClear
    je .clear
    cmp [wParam], idClose
    je .close
    jmp .finish

    .clear:
      mov [number], 0
      stdcall Repaint,[hwnd]
      jmp .finish

    .drawCirculo:
      stdcall ResetRect
      mov [number], 1
      stdcall Repaint,[hwnd]
      invoke SetFocus,[hwnd]
      jmp .finish

    .drawCuadrado:
      stdcall ResetRect
      mov [number], 2
      stdcall Repaint,[hwnd]
      invoke SetFocus,[hwnd]
      jmp .finish

    .drawTriangulo:
      stdcall ResetRect
      push eax ecx
      mov eax, 0
      mov edx, 0
      mov eax, [rect.right]
      sub eax, [rect.left]
      mov ecx, 2
      div ecx
      add [rect.left], 25
      mov [number], 3
      pop ecx eax
      stdcall Repaint,[hwnd]
      invoke SetFocus,[hwnd]
      jmp .finish
    
    .close:
      invoke SendMessage,[hwnd],WM_CLOSE,0,0
      jmp .finish

  .capturarTecla:
    cmp [wParam], VK_UP
    je .top
    cmp [wParam], VK_DOWN
    je .down
    cmp [wParam], VK_LEFT
    je .left
    cmp [wParam], VK_RIGHT
    je .right
    jmp .finish
    .top:
      stdcall MoveTop
      stdcall Repaint,[hwnd]
      jmp .finish
    .down:
      stdcall MoveDown
      stdcall Repaint,[hwnd]
      jmp .finish
    .left:
      stdcall MoveLeft
      stdcall Repaint,[hwnd]
      jmp .finish
    .right:
      stdcall MoveRight
      stdcall Repaint,[hwnd]
    jmp .finish

  .paint:
    stdcall Draw,[hwnd]
    jmp .finish

  .wclose:
    invoke  ExitProcess,0
    jmp .finish

  .wmdestroy:
    invoke  PostQuitMessage,0
    xor     eax,eax
  .finish:
ret
endp

proc MoveTop
  sub [rect.top], 5
  sub [rect.bottom], 5
ret
endp

proc MoveDown
  add [rect.top], 5
  add [rect.bottom], 5
ret
endp

proc MoveLeft
  sub [rect.left], 5
  sub [rect.right], 5
ret
endp

proc MoveRight
  add [rect.left], 5
  add [rect.right], 5
ret
endp

proc Repaint hwnd
  invoke RedrawWindow,[hwnd],panel,NULL,\
	     RDW_ERASE+RDW_INVALIDATE
ret
endp

proc CrearBotones hwnd
  invoke CreateWindowEx,0,typeBoton,labelCirculo,\
	    WS_VISIBLE+WS_CHILD,15,320,70,30,[hwnd],idCirculo,[wc.hInstance],NULL
  invoke CreateWindowEx,0,typeBoton,labelCuadrado,\
	    WS_VISIBLE+WS_CHILD,95,320,70,30,[hwnd],idCuadrado,[wc.hInstance],NULL
  invoke CreateWindowEx,0,typeBoton,labelTriangulo,\
	    WS_VISIBLE+WS_CHILD,175,320,70,30,[hwnd],idTriangulo,[wc.hInstance],NULL
  invoke CreateWindowEx,0,typeBoton,labelClear,\
	    WS_VISIBLE+WS_CHILD,255,320,70,30,[hwnd],idClear,[wc.hInstance],NULL

  invoke CreateWindowEx,0,typeBoton,labelClose,\
	    WS_VISIBLE+WS_CHILD,410,320,70,30,[hwnd],idClose,[wc.hInstance],NULL
ret
endp

proc ResetRect
  mov [rect.top], 120
  mov [rect.left],220
  mov [rect.bottom],180
  mov [rect.right],280
ret
endp

proc Draw hwnd
  invoke BeginPaint,[hwnd], lapiz
  mov [hdc], eax
  invoke CreatePen,PS_SOLID,1,00000000h
  mov [hPen], eax
  invoke SelectObject,[hdc],[hPen]
  mov [hPenOld], eax

  stdcall CambiaColorFondo, 00D0DE9Eh, [hdc]
  invoke Rectangle,[lapiz.hdc],\
	   [panel.left],[panel.top],[panel.right],[panel.bottom]

  stdcall CambiaColorFondo, 00F39E89h, [hdc]

  cmp [number], 0
  je .finPaint
  cmp [number], 1
  je .paintCirculo
  cmp [number], 2
  je .paintRectangulo
  cmp [number], 3
  je .paintTriangulo
  jmp .finPaint

  .paintCirculo:
    invoke Ellipse,[lapiz.hdc],\
	   [rect.left],[rect.top],[rect.right],[rect.bottom]
    jmp .finPaint

  .paintRectangulo:
    invoke Rectangle,[lapiz.hdc],\
	   [rect.left],[rect.top],[rect.right],[rect.bottom]
    jmp .finPaint

  .paintTriangulo:
    stdcall Triangle

  .finPaint:
    invoke EndPaint,[hwnd],lapiz
ret
endp

proc Triangle
  push ebx
  mov ebx, 0
  mov ebx, [rect.right]
  sub ebx, [rect.left]

  invoke BeginPath,[lapiz.hdc]
  invoke MoveToEx,[lapiz.hdc],[rect.left],[rect.top],0
  sub [rect.left],ebx
  invoke LineTo,[lapiz.hdc],[rect.left],[rect.bottom]
  invoke LineTo,[lapiz.hdc],[rect.right],[rect.bottom]
  add [rect.left],ebx
  invoke LineTo,[lapiz.hdc],[rect.left],[rect.top]
  invoke EndPath,[lapiz.hdc]
  invoke FillPath,[lapiz.hdc]

  invoke MoveToEx,[lapiz.hdc],[rect.left],[rect.top],0
  sub [rect.left],ebx
  invoke LineTo,[lapiz.hdc],[rect.left],[rect.bottom]
  invoke LineTo,[lapiz.hdc],[rect.right],[rect.bottom]
  add [rect.left],ebx
  invoke LineTo,[lapiz.hdc],[rect.left],[rect.top]

  pop ebx
ret
endp

proc  CambiaColorFondo newColor, uhdc
    mov       [ulb.lbStyle], BS_SOLID
    mov       eax, [newColor]
    mov       [ulb.lbColor], eax
    mov       [ulb.lbHatch], NULL
    invoke    CreateBrushIndirect, ulb
    mov       [uhBrush], eax
    invoke    SelectObject,[uhdc],[uhBrush]
    ret
endp


section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL',\
	  gdi32,   'GDI32.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'
  include 'c:\fasm\include\api\gdi32.inc'