
obj/user/softint:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 c9 00 00 00       	call   800113 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800052:	c1 e0 05             	shl    $0x5,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800089:	6a 00                	push   $0x0
  80008b:	e8 42 00 00 00       	call   8000d2 <sys_env_destroy>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5f                   	pop    %edi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000be:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c3:	89 d1                	mov    %edx,%ecx
  8000c5:	89 d3                	mov    %edx,%ebx
  8000c7:	89 d7                	mov    %edx,%edi
  8000c9:	89 d6                	mov    %edx,%esi
  8000cb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	89 cb                	mov    %ecx,%ebx
  8000ea:	89 cf                	mov    %ecx,%edi
  8000ec:	89 ce                	mov    %ecx,%esi
  8000ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	7e 17                	jle    80010b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	6a 03                	push   $0x3
  8000fa:	68 0a 0e 80 00       	push   $0x800e0a
  8000ff:	6a 23                	push   $0x23
  800101:	68 27 0e 80 00       	push   $0x800e27
  800106:	e8 27 00 00 00       	call   800132 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800119:	ba 00 00 00 00       	mov    $0x0,%edx
  80011e:	b8 02 00 00 00       	mov    $0x2,%eax
  800123:	89 d1                	mov    %edx,%ecx
  800125:	89 d3                	mov    %edx,%ebx
  800127:	89 d7                	mov    %edx,%edi
  800129:	89 d6                	mov    %edx,%esi
  80012b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800137:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800140:	e8 ce ff ff ff       	call   800113 <sys_getenvid>
  800145:	83 ec 0c             	sub    $0xc,%esp
  800148:	ff 75 0c             	pushl  0xc(%ebp)
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	56                   	push   %esi
  80014f:	50                   	push   %eax
  800150:	68 38 0e 80 00       	push   $0x800e38
  800155:	e8 b1 00 00 00       	call   80020b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015a:	83 c4 18             	add    $0x18,%esp
  80015d:	53                   	push   %ebx
  80015e:	ff 75 10             	pushl  0x10(%ebp)
  800161:	e8 54 00 00 00       	call   8001ba <vcprintf>
	cprintf("\n");
  800166:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  80016d:	e8 99 00 00 00       	call   80020b <cprintf>
  800172:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800175:	cc                   	int3   
  800176:	eb fd                	jmp    800175 <_panic+0x43>

00800178 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	53                   	push   %ebx
  80017c:	83 ec 04             	sub    $0x4,%esp
  80017f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800182:	8b 13                	mov    (%ebx),%edx
  800184:	8d 42 01             	lea    0x1(%edx),%eax
  800187:	89 03                	mov    %eax,(%ebx)
  800189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800190:	3d ff 00 00 00       	cmp    $0xff,%eax
  800195:	75 1a                	jne    8001b1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800197:	83 ec 08             	sub    $0x8,%esp
  80019a:	68 ff 00 00 00       	push   $0xff
  80019f:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a2:	50                   	push   %eax
  8001a3:	e8 ed fe ff ff       	call   800095 <sys_cputs>
		b->idx = 0;
  8001a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ae:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ca:	00 00 00 
	b.cnt = 0;
  8001cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d7:	ff 75 0c             	pushl  0xc(%ebp)
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	68 78 01 80 00       	push   $0x800178
  8001e9:	e8 1a 01 00 00       	call   800308 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ee:	83 c4 08             	add    $0x8,%esp
  8001f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fd:	50                   	push   %eax
  8001fe:	e8 92 fe ff ff       	call   800095 <sys_cputs>

	return b.cnt;
}
  800203:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800211:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800214:	50                   	push   %eax
  800215:	ff 75 08             	pushl  0x8(%ebp)
  800218:	e8 9d ff ff ff       	call   8001ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 1c             	sub    $0x1c,%esp
  800228:	89 c7                	mov    %eax,%edi
  80022a:	89 d6                	mov    %edx,%esi
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800232:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800235:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800240:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800243:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800246:	39 d3                	cmp    %edx,%ebx
  800248:	72 05                	jb     80024f <printnum+0x30>
  80024a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024d:	77 45                	ja     800294 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	ff 75 18             	pushl  0x18(%ebp)
  800255:	8b 45 14             	mov    0x14(%ebp),%eax
  800258:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025b:	53                   	push   %ebx
  80025c:	ff 75 10             	pushl  0x10(%ebp)
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	ff 75 e4             	pushl  -0x1c(%ebp)
  800265:	ff 75 e0             	pushl  -0x20(%ebp)
  800268:	ff 75 dc             	pushl  -0x24(%ebp)
  80026b:	ff 75 d8             	pushl  -0x28(%ebp)
  80026e:	e8 ed 08 00 00       	call   800b60 <__udivdi3>
  800273:	83 c4 18             	add    $0x18,%esp
  800276:	52                   	push   %edx
  800277:	50                   	push   %eax
  800278:	89 f2                	mov    %esi,%edx
  80027a:	89 f8                	mov    %edi,%eax
  80027c:	e8 9e ff ff ff       	call   80021f <printnum>
  800281:	83 c4 20             	add    $0x20,%esp
  800284:	eb 18                	jmp    80029e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	ff 75 18             	pushl  0x18(%ebp)
  80028d:	ff d7                	call   *%edi
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	eb 03                	jmp    800297 <printnum+0x78>
  800294:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800297:	83 eb 01             	sub    $0x1,%ebx
  80029a:	85 db                	test   %ebx,%ebx
  80029c:	7f e8                	jg     800286 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	83 ec 04             	sub    $0x4,%esp
  8002a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b1:	e8 da 09 00 00       	call   800c90 <__umoddi3>
  8002b6:	83 c4 14             	add    $0x14,%esp
  8002b9:	0f be 80 5e 0e 80 00 	movsbl 0x800e5e(%eax),%eax
  8002c0:	50                   	push   %eax
  8002c1:	ff d7                	call   *%edi
}
  8002c3:	83 c4 10             	add    $0x10,%esp
  8002c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dd:	73 0a                	jae    8002e9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002df:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e7:	88 02                	mov    %al,(%edx)
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f4:	50                   	push   %eax
  8002f5:	ff 75 10             	pushl  0x10(%ebp)
  8002f8:	ff 75 0c             	pushl  0xc(%ebp)
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 05 00 00 00       	call   800308 <vprintfmt>
	va_end(ap);
}
  800303:	83 c4 10             	add    $0x10,%esp
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	57                   	push   %edi
  80030c:	56                   	push   %esi
  80030d:	53                   	push   %ebx
  80030e:	83 ec 2c             	sub    $0x2c,%esp
  800311:	8b 75 08             	mov    0x8(%ebp),%esi
  800314:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800317:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031a:	eb 12                	jmp    80032e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031c:	85 c0                	test   %eax,%eax
  80031e:	0f 84 42 04 00 00    	je     800766 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800324:	83 ec 08             	sub    $0x8,%esp
  800327:	53                   	push   %ebx
  800328:	50                   	push   %eax
  800329:	ff d6                	call   *%esi
  80032b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032e:	83 c7 01             	add    $0x1,%edi
  800331:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800335:	83 f8 25             	cmp    $0x25,%eax
  800338:	75 e2                	jne    80031c <vprintfmt+0x14>
  80033a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80033e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800345:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800353:	b9 00 00 00 00       	mov    $0x0,%ecx
  800358:	eb 07                	jmp    800361 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8d 47 01             	lea    0x1(%edi),%eax
  800364:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800367:	0f b6 07             	movzbl (%edi),%eax
  80036a:	0f b6 d0             	movzbl %al,%edx
  80036d:	83 e8 23             	sub    $0x23,%eax
  800370:	3c 55                	cmp    $0x55,%al
  800372:	0f 87 d3 03 00 00    	ja     80074b <vprintfmt+0x443>
  800378:	0f b6 c0             	movzbl %al,%eax
  80037b:	ff 24 85 00 0f 80 00 	jmp    *0x800f00(,%eax,4)
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800385:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800389:	eb d6                	jmp    800361 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038e:	b8 00 00 00 00       	mov    $0x0,%eax
  800393:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800396:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800399:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a3:	83 f9 09             	cmp    $0x9,%ecx
  8003a6:	77 3f                	ja     8003e7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ab:	eb e9                	jmp    800396 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 40 04             	lea    0x4(%eax),%eax
  8003bb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c1:	eb 2a                	jmp    8003ed <vprintfmt+0xe5>
  8003c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	0f 49 d0             	cmovns %eax,%edx
  8003d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d6:	eb 89                	jmp    800361 <vprintfmt+0x59>
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e2:	e9 7a ff ff ff       	jmp    800361 <vprintfmt+0x59>
  8003e7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f1:	0f 89 6a ff ff ff    	jns    800361 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800404:	e9 58 ff ff ff       	jmp    800361 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800409:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040f:	e9 4d ff ff ff       	jmp    800361 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 78 04             	lea    0x4(%eax),%edi
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 30                	pushl  (%eax)
  800420:	ff d6                	call   *%esi
			break;
  800422:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800425:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042b:	e9 fe fe ff ff       	jmp    80032e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 78 04             	lea    0x4(%eax),%edi
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 07             	cmp    $0x7,%eax
  800440:	7f 0b                	jg     80044d <vprintfmt+0x145>
  800442:	8b 14 85 60 10 80 00 	mov    0x801060(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 1b                	jne    800468 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 76 0e 80 00       	push   $0x800e76
  800453:	53                   	push   %ebx
  800454:	56                   	push   %esi
  800455:	e8 91 fe ff ff       	call   8002eb <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 c6 fe ff ff       	jmp    80032e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	52                   	push   %edx
  800469:	68 7f 0e 80 00       	push   $0x800e7f
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 76 fe ff ff       	call   8002eb <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047e:	e9 ab fe ff ff       	jmp    80032e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	83 c0 04             	add    $0x4,%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800491:	85 ff                	test   %edi,%edi
  800493:	b8 6f 0e 80 00       	mov    $0x800e6f,%eax
  800498:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049f:	0f 8e 94 00 00 00    	jle    800539 <vprintfmt+0x231>
  8004a5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a9:	0f 84 98 00 00 00    	je     800547 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b5:	57                   	push   %edi
  8004b6:	e8 33 03 00 00       	call   8007ee <strnlen>
  8004bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004be:	29 c1                	sub    %eax,%ecx
  8004c0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004c3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	eb 0f                	jmp    8004e3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	53                   	push   %ebx
  8004d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004db:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dd:	83 ef 01             	sub    $0x1,%edi
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	85 ff                	test   %edi,%edi
  8004e5:	7f ed                	jg     8004d4 <vprintfmt+0x1cc>
  8004e7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ea:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f4:	0f 49 c1             	cmovns %ecx,%eax
  8004f7:	29 c1                	sub    %eax,%ecx
  8004f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800502:	89 cb                	mov    %ecx,%ebx
  800504:	eb 4d                	jmp    800553 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800506:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050a:	74 1b                	je     800527 <vprintfmt+0x21f>
  80050c:	0f be c0             	movsbl %al,%eax
  80050f:	83 e8 20             	sub    $0x20,%eax
  800512:	83 f8 5e             	cmp    $0x5e,%eax
  800515:	76 10                	jbe    800527 <vprintfmt+0x21f>
					putch('?', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	ff 75 0c             	pushl  0xc(%ebp)
  80051d:	6a 3f                	push   $0x3f
  80051f:	ff 55 08             	call   *0x8(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	eb 0d                	jmp    800534 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	52                   	push   %edx
  80052e:	ff 55 08             	call   *0x8(%ebp)
  800531:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800534:	83 eb 01             	sub    $0x1,%ebx
  800537:	eb 1a                	jmp    800553 <vprintfmt+0x24b>
  800539:	89 75 08             	mov    %esi,0x8(%ebp)
  80053c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800542:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800545:	eb 0c                	jmp    800553 <vprintfmt+0x24b>
  800547:	89 75 08             	mov    %esi,0x8(%ebp)
  80054a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800550:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800553:	83 c7 01             	add    $0x1,%edi
  800556:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055a:	0f be d0             	movsbl %al,%edx
  80055d:	85 d2                	test   %edx,%edx
  80055f:	74 23                	je     800584 <vprintfmt+0x27c>
  800561:	85 f6                	test   %esi,%esi
  800563:	78 a1                	js     800506 <vprintfmt+0x1fe>
  800565:	83 ee 01             	sub    $0x1,%esi
  800568:	79 9c                	jns    800506 <vprintfmt+0x1fe>
  80056a:	89 df                	mov    %ebx,%edi
  80056c:	8b 75 08             	mov    0x8(%ebp),%esi
  80056f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800572:	eb 18                	jmp    80058c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	53                   	push   %ebx
  800578:	6a 20                	push   $0x20
  80057a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057c:	83 ef 01             	sub    $0x1,%edi
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	eb 08                	jmp    80058c <vprintfmt+0x284>
  800584:	89 df                	mov    %ebx,%edi
  800586:	8b 75 08             	mov    0x8(%ebp),%esi
  800589:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058c:	85 ff                	test   %edi,%edi
  80058e:	7f e4                	jg     800574 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800590:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800599:	e9 90 fd ff ff       	jmp    80032e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059e:	83 f9 01             	cmp    $0x1,%ecx
  8005a1:	7e 19                	jle    8005bc <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 50 04             	mov    0x4(%eax),%edx
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 40 08             	lea    0x8(%eax),%eax
  8005b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ba:	eb 38                	jmp    8005f4 <vprintfmt+0x2ec>
	else if (lflag)
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	74 1b                	je     8005db <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	89 c1                	mov    %eax,%ecx
  8005ca:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d9:	eb 19                	jmp    8005f4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800603:	0f 89 0e 01 00 00    	jns    800717 <vprintfmt+0x40f>
				putch('-', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 2d                	push   $0x2d
  80060f:	ff d6                	call   *%esi
				num = -(long long) num;
  800611:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800614:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800617:	f7 da                	neg    %edx
  800619:	83 d1 00             	adc    $0x0,%ecx
  80061c:	f7 d9                	neg    %ecx
  80061e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
  800626:	e9 ec 00 00 00       	jmp    800717 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062b:	83 f9 01             	cmp    $0x1,%ecx
  80062e:	7e 18                	jle    800648 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	8b 48 04             	mov    0x4(%eax),%ecx
  800638:	8d 40 08             	lea    0x8(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 cf 00 00 00       	jmp    800717 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800648:	85 c9                	test   %ecx,%ecx
  80064a:	74 1a                	je     800666 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 b1 00 00 00       	jmp    800717 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800676:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067b:	e9 97 00 00 00       	jmp    800717 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 58                	push   $0x58
  800686:	ff d6                	call   *%esi
			putch('X', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 58                	push   $0x58
  80068e:	ff d6                	call   *%esi
			putch('X', putdat);
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 58                	push   $0x58
  800696:	ff d6                	call   *%esi
			break;
  800698:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80069e:	e9 8b fc ff ff       	jmp    80032e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 30                	push   $0x30
  8006a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 78                	push   $0x78
  8006b1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006bd:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c0:	8d 40 04             	lea    0x4(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cb:	eb 4a                	jmp    800717 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cd:	83 f9 01             	cmp    $0x1,%ecx
  8006d0:	7e 15                	jle    8006e7 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 10                	mov    (%eax),%edx
  8006d7:	8b 48 04             	mov    0x4(%eax),%ecx
  8006da:	8d 40 08             	lea    0x8(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e5:	eb 30                	jmp    800717 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006e7:	85 c9                	test   %ecx,%ecx
  8006e9:	74 17                	je     800702 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 10                	mov    (%eax),%edx
  8006f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
  800700:	eb 15                	jmp    800717 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 10                	mov    (%eax),%edx
  800707:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070c:	8d 40 04             	lea    0x4(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800712:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800717:	83 ec 0c             	sub    $0xc,%esp
  80071a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80071e:	57                   	push   %edi
  80071f:	ff 75 e0             	pushl  -0x20(%ebp)
  800722:	50                   	push   %eax
  800723:	51                   	push   %ecx
  800724:	52                   	push   %edx
  800725:	89 da                	mov    %ebx,%edx
  800727:	89 f0                	mov    %esi,%eax
  800729:	e8 f1 fa ff ff       	call   80021f <printnum>
			break;
  80072e:	83 c4 20             	add    $0x20,%esp
  800731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800734:	e9 f5 fb ff ff       	jmp    80032e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	52                   	push   %edx
  80073e:	ff d6                	call   *%esi
			break;
  800740:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800746:	e9 e3 fb ff ff       	jmp    80032e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	6a 25                	push   $0x25
  800751:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb 03                	jmp    80075b <vprintfmt+0x453>
  800758:	83 ef 01             	sub    $0x1,%edi
  80075b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80075f:	75 f7                	jne    800758 <vprintfmt+0x450>
  800761:	e9 c8 fb ff ff       	jmp    80032e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800766:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 18             	sub    $0x18,%esp
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800781:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800784:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078b:	85 c0                	test   %eax,%eax
  80078d:	74 26                	je     8007b5 <vsnprintf+0x47>
  80078f:	85 d2                	test   %edx,%edx
  800791:	7e 22                	jle    8007b5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800793:	ff 75 14             	pushl  0x14(%ebp)
  800796:	ff 75 10             	pushl  0x10(%ebp)
  800799:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079c:	50                   	push   %eax
  80079d:	68 ce 02 80 00       	push   $0x8002ce
  8007a2:	e8 61 fb ff ff       	call   800308 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	eb 05                	jmp    8007ba <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c5:	50                   	push   %eax
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	ff 75 08             	pushl  0x8(%ebp)
  8007cf:	e8 9a ff ff ff       	call   80076e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 03                	jmp    8007e6 <strlen+0x10>
		n++;
  8007e3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ea:	75 f7                	jne    8007e3 <strlen+0xd>
		n++;
	return n;
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fc:	eb 03                	jmp    800801 <strnlen+0x13>
		n++;
  8007fe:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	39 c2                	cmp    %eax,%edx
  800803:	74 08                	je     80080d <strnlen+0x1f>
  800805:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800809:	75 f3                	jne    8007fe <strnlen+0x10>
  80080b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	89 c2                	mov    %eax,%edx
  80081b:	83 c2 01             	add    $0x1,%edx
  80081e:	83 c1 01             	add    $0x1,%ecx
  800821:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
  800828:	84 db                	test   %bl,%bl
  80082a:	75 ef                	jne    80081b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082c:	5b                   	pop    %ebx
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	53                   	push   %ebx
  800837:	e8 9a ff ff ff       	call   8007d6 <strlen>
  80083c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	01 d8                	add    %ebx,%eax
  800844:	50                   	push   %eax
  800845:	e8 c5 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084a:	89 d8                	mov    %ebx,%eax
  80084c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 75 08             	mov    0x8(%ebp),%esi
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085c:	89 f3                	mov    %esi,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	89 f2                	mov    %esi,%edx
  800863:	eb 0f                	jmp    800874 <strncpy+0x23>
		*dst++ = *src;
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	0f b6 01             	movzbl (%ecx),%eax
  80086b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086e:	80 39 01             	cmpb   $0x1,(%ecx)
  800871:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	39 da                	cmp    %ebx,%edx
  800876:	75 ed                	jne    800865 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800878:	89 f0                	mov    %esi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	8b 55 10             	mov    0x10(%ebp),%edx
  80088c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	74 21                	je     8008b3 <strlcpy+0x35>
  800892:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800896:	89 f2                	mov    %esi,%edx
  800898:	eb 09                	jmp    8008a3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089a:	83 c2 01             	add    $0x1,%edx
  80089d:	83 c1 01             	add    $0x1,%ecx
  8008a0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a3:	39 c2                	cmp    %eax,%edx
  8008a5:	74 09                	je     8008b0 <strlcpy+0x32>
  8008a7:	0f b6 19             	movzbl (%ecx),%ebx
  8008aa:	84 db                	test   %bl,%bl
  8008ac:	75 ec                	jne    80089a <strlcpy+0x1c>
  8008ae:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b3:	29 f0                	sub    %esi,%eax
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c2:	eb 06                	jmp    8008ca <strcmp+0x11>
		p++, q++;
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ca:	0f b6 01             	movzbl (%ecx),%eax
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 04                	je     8008d5 <strcmp+0x1c>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	74 ef                	je     8008c4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d5:	0f b6 c0             	movzbl %al,%eax
  8008d8:	0f b6 12             	movzbl (%edx),%edx
  8008db:	29 d0                	sub    %edx,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ee:	eb 06                	jmp    8008f6 <strncmp+0x17>
		n--, p++, q++;
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f6:	39 d8                	cmp    %ebx,%eax
  8008f8:	74 15                	je     80090f <strncmp+0x30>
  8008fa:	0f b6 08             	movzbl (%eax),%ecx
  8008fd:	84 c9                	test   %cl,%cl
  8008ff:	74 04                	je     800905 <strncmp+0x26>
  800901:	3a 0a                	cmp    (%edx),%cl
  800903:	74 eb                	je     8008f0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800905:	0f b6 00             	movzbl (%eax),%eax
  800908:	0f b6 12             	movzbl (%edx),%edx
  80090b:	29 d0                	sub    %edx,%eax
  80090d:	eb 05                	jmp    800914 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800914:	5b                   	pop    %ebx
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800921:	eb 07                	jmp    80092a <strchr+0x13>
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 0f                	je     800936 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
  80092d:	84 d2                	test   %dl,%dl
  80092f:	75 f2                	jne    800923 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800942:	eb 03                	jmp    800947 <strfind+0xf>
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 04                	je     800952 <strfind+0x1a>
  80094e:	84 d2                	test   %dl,%dl
  800950:	75 f2                	jne    800944 <strfind+0xc>
			break;
	return (char *) s;
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800960:	85 c9                	test   %ecx,%ecx
  800962:	74 36                	je     80099a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800964:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096a:	75 28                	jne    800994 <memset+0x40>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 23                	jne    800994 <memset+0x40>
		c &= 0xFF;
  800971:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d3                	mov    %edx,%ebx
  800977:	c1 e3 08             	shl    $0x8,%ebx
  80097a:	89 d6                	mov    %edx,%esi
  80097c:	c1 e6 18             	shl    $0x18,%esi
  80097f:	89 d0                	mov    %edx,%eax
  800981:	c1 e0 10             	shl    $0x10,%eax
  800984:	09 f0                	or     %esi,%eax
  800986:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800988:	89 d8                	mov    %ebx,%eax
  80098a:	09 d0                	or     %edx,%eax
  80098c:	c1 e9 02             	shr    $0x2,%ecx
  80098f:	fc                   	cld    
  800990:	f3 ab                	rep stos %eax,%es:(%edi)
  800992:	eb 06                	jmp    80099a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	fc                   	cld    
  800998:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099a:	89 f8                	mov    %edi,%eax
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009af:	39 c6                	cmp    %eax,%esi
  8009b1:	73 35                	jae    8009e8 <memmove+0x47>
  8009b3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	73 2e                	jae    8009e8 <memmove+0x47>
		s += n;
		d += n;
  8009ba:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	89 d6                	mov    %edx,%esi
  8009bf:	09 fe                	or     %edi,%esi
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 13                	jne    8009dc <memmove+0x3b>
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 0e                	jne    8009dc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ce:	83 ef 04             	sub    $0x4,%edi
  8009d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
  8009d7:	fd                   	std    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 09                	jmp    8009e5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009dc:	83 ef 01             	sub    $0x1,%edi
  8009df:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e2:	fd                   	std    
  8009e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e5:	fc                   	cld    
  8009e6:	eb 1d                	jmp    800a05 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e8:	89 f2                	mov    %esi,%edx
  8009ea:	09 c2                	or     %eax,%edx
  8009ec:	f6 c2 03             	test   $0x3,%dl
  8009ef:	75 0f                	jne    800a00 <memmove+0x5f>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 0a                	jne    800a00 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f6:	c1 e9 02             	shr    $0x2,%ecx
  8009f9:	89 c7                	mov    %eax,%edi
  8009fb:	fc                   	cld    
  8009fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fe:	eb 05                	jmp    800a05 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a00:	89 c7                	mov    %eax,%edi
  800a02:	fc                   	cld    
  800a03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a05:	5e                   	pop    %esi
  800a06:	5f                   	pop    %edi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0c:	ff 75 10             	pushl  0x10(%ebp)
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	ff 75 08             	pushl  0x8(%ebp)
  800a15:	e8 87 ff ff ff       	call   8009a1 <memmove>
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a27:	89 c6                	mov    %eax,%esi
  800a29:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2c:	eb 1a                	jmp    800a48 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2e:	0f b6 08             	movzbl (%eax),%ecx
  800a31:	0f b6 1a             	movzbl (%edx),%ebx
  800a34:	38 d9                	cmp    %bl,%cl
  800a36:	74 0a                	je     800a42 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a38:	0f b6 c1             	movzbl %cl,%eax
  800a3b:	0f b6 db             	movzbl %bl,%ebx
  800a3e:	29 d8                	sub    %ebx,%eax
  800a40:	eb 0f                	jmp    800a51 <memcmp+0x35>
		s1++, s2++;
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a48:	39 f0                	cmp    %esi,%eax
  800a4a:	75 e2                	jne    800a2e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	53                   	push   %ebx
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5c:	89 c1                	mov    %eax,%ecx
  800a5e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	eb 0a                	jmp    800a71 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a67:	0f b6 10             	movzbl (%eax),%edx
  800a6a:	39 da                	cmp    %ebx,%edx
  800a6c:	74 07                	je     800a75 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	39 c8                	cmp    %ecx,%eax
  800a73:	72 f2                	jb     800a67 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a84:	eb 03                	jmp    800a89 <strtol+0x11>
		s++;
  800a86:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a89:	0f b6 01             	movzbl (%ecx),%eax
  800a8c:	3c 20                	cmp    $0x20,%al
  800a8e:	74 f6                	je     800a86 <strtol+0xe>
  800a90:	3c 09                	cmp    $0x9,%al
  800a92:	74 f2                	je     800a86 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a94:	3c 2b                	cmp    $0x2b,%al
  800a96:	75 0a                	jne    800aa2 <strtol+0x2a>
		s++;
  800a98:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa0:	eb 11                	jmp    800ab3 <strtol+0x3b>
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa7:	3c 2d                	cmp    $0x2d,%al
  800aa9:	75 08                	jne    800ab3 <strtol+0x3b>
		s++, neg = 1;
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab9:	75 15                	jne    800ad0 <strtol+0x58>
  800abb:	80 39 30             	cmpb   $0x30,(%ecx)
  800abe:	75 10                	jne    800ad0 <strtol+0x58>
  800ac0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac4:	75 7c                	jne    800b42 <strtol+0xca>
		s += 2, base = 16;
  800ac6:	83 c1 02             	add    $0x2,%ecx
  800ac9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ace:	eb 16                	jmp    800ae6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad0:	85 db                	test   %ebx,%ebx
  800ad2:	75 12                	jne    800ae6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad9:	80 39 30             	cmpb   $0x30,(%ecx)
  800adc:	75 08                	jne    800ae6 <strtol+0x6e>
		s++, base = 8;
  800ade:	83 c1 01             	add    $0x1,%ecx
  800ae1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aee:	0f b6 11             	movzbl (%ecx),%edx
  800af1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	80 fb 09             	cmp    $0x9,%bl
  800af9:	77 08                	ja     800b03 <strtol+0x8b>
			dig = *s - '0';
  800afb:	0f be d2             	movsbl %dl,%edx
  800afe:	83 ea 30             	sub    $0x30,%edx
  800b01:	eb 22                	jmp    800b25 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b03:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 08                	ja     800b15 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 57             	sub    $0x57,%edx
  800b13:	eb 10                	jmp    800b25 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b15:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b18:	89 f3                	mov    %esi,%ebx
  800b1a:	80 fb 19             	cmp    $0x19,%bl
  800b1d:	77 16                	ja     800b35 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b1f:	0f be d2             	movsbl %dl,%edx
  800b22:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b25:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b28:	7d 0b                	jge    800b35 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b31:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b33:	eb b9                	jmp    800aee <strtol+0x76>

	if (endptr)
  800b35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b39:	74 0d                	je     800b48 <strtol+0xd0>
		*endptr = (char *) s;
  800b3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3e:	89 0e                	mov    %ecx,(%esi)
  800b40:	eb 06                	jmp    800b48 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b42:	85 db                	test   %ebx,%ebx
  800b44:	74 98                	je     800ade <strtol+0x66>
  800b46:	eb 9e                	jmp    800ae6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b48:	89 c2                	mov    %eax,%edx
  800b4a:	f7 da                	neg    %edx
  800b4c:	85 ff                	test   %edi,%edi
  800b4e:	0f 45 c2             	cmovne %edx,%eax
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    
  800b56:	66 90                	xchg   %ax,%ax
  800b58:	66 90                	xchg   %ax,%ax
  800b5a:	66 90                	xchg   %ax,%ax
  800b5c:	66 90                	xchg   %ax,%ax
  800b5e:	66 90                	xchg   %ax,%ax

00800b60 <__udivdi3>:
  800b60:	55                   	push   %ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 1c             	sub    $0x1c,%esp
  800b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b77:	85 f6                	test   %esi,%esi
  800b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b7d:	89 ca                	mov    %ecx,%edx
  800b7f:	89 f8                	mov    %edi,%eax
  800b81:	75 3d                	jne    800bc0 <__udivdi3+0x60>
  800b83:	39 cf                	cmp    %ecx,%edi
  800b85:	0f 87 c5 00 00 00    	ja     800c50 <__udivdi3+0xf0>
  800b8b:	85 ff                	test   %edi,%edi
  800b8d:	89 fd                	mov    %edi,%ebp
  800b8f:	75 0b                	jne    800b9c <__udivdi3+0x3c>
  800b91:	b8 01 00 00 00       	mov    $0x1,%eax
  800b96:	31 d2                	xor    %edx,%edx
  800b98:	f7 f7                	div    %edi
  800b9a:	89 c5                	mov    %eax,%ebp
  800b9c:	89 c8                	mov    %ecx,%eax
  800b9e:	31 d2                	xor    %edx,%edx
  800ba0:	f7 f5                	div    %ebp
  800ba2:	89 c1                	mov    %eax,%ecx
  800ba4:	89 d8                	mov    %ebx,%eax
  800ba6:	89 cf                	mov    %ecx,%edi
  800ba8:	f7 f5                	div    %ebp
  800baa:	89 c3                	mov    %eax,%ebx
  800bac:	89 d8                	mov    %ebx,%eax
  800bae:	89 fa                	mov    %edi,%edx
  800bb0:	83 c4 1c             	add    $0x1c,%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    
  800bb8:	90                   	nop
  800bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bc0:	39 ce                	cmp    %ecx,%esi
  800bc2:	77 74                	ja     800c38 <__udivdi3+0xd8>
  800bc4:	0f bd fe             	bsr    %esi,%edi
  800bc7:	83 f7 1f             	xor    $0x1f,%edi
  800bca:	0f 84 98 00 00 00    	je     800c68 <__udivdi3+0x108>
  800bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bd5:	89 f9                	mov    %edi,%ecx
  800bd7:	89 c5                	mov    %eax,%ebp
  800bd9:	29 fb                	sub    %edi,%ebx
  800bdb:	d3 e6                	shl    %cl,%esi
  800bdd:	89 d9                	mov    %ebx,%ecx
  800bdf:	d3 ed                	shr    %cl,%ebp
  800be1:	89 f9                	mov    %edi,%ecx
  800be3:	d3 e0                	shl    %cl,%eax
  800be5:	09 ee                	or     %ebp,%esi
  800be7:	89 d9                	mov    %ebx,%ecx
  800be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bed:	89 d5                	mov    %edx,%ebp
  800bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bf3:	d3 ed                	shr    %cl,%ebp
  800bf5:	89 f9                	mov    %edi,%ecx
  800bf7:	d3 e2                	shl    %cl,%edx
  800bf9:	89 d9                	mov    %ebx,%ecx
  800bfb:	d3 e8                	shr    %cl,%eax
  800bfd:	09 c2                	or     %eax,%edx
  800bff:	89 d0                	mov    %edx,%eax
  800c01:	89 ea                	mov    %ebp,%edx
  800c03:	f7 f6                	div    %esi
  800c05:	89 d5                	mov    %edx,%ebp
  800c07:	89 c3                	mov    %eax,%ebx
  800c09:	f7 64 24 0c          	mull   0xc(%esp)
  800c0d:	39 d5                	cmp    %edx,%ebp
  800c0f:	72 10                	jb     800c21 <__udivdi3+0xc1>
  800c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c15:	89 f9                	mov    %edi,%ecx
  800c17:	d3 e6                	shl    %cl,%esi
  800c19:	39 c6                	cmp    %eax,%esi
  800c1b:	73 07                	jae    800c24 <__udivdi3+0xc4>
  800c1d:	39 d5                	cmp    %edx,%ebp
  800c1f:	75 03                	jne    800c24 <__udivdi3+0xc4>
  800c21:	83 eb 01             	sub    $0x1,%ebx
  800c24:	31 ff                	xor    %edi,%edi
  800c26:	89 d8                	mov    %ebx,%eax
  800c28:	89 fa                	mov    %edi,%edx
  800c2a:	83 c4 1c             	add    $0x1c,%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
  800c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c38:	31 ff                	xor    %edi,%edi
  800c3a:	31 db                	xor    %ebx,%ebx
  800c3c:	89 d8                	mov    %ebx,%eax
  800c3e:	89 fa                	mov    %edi,%edx
  800c40:	83 c4 1c             	add    $0x1c,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    
  800c48:	90                   	nop
  800c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c50:	89 d8                	mov    %ebx,%eax
  800c52:	f7 f7                	div    %edi
  800c54:	31 ff                	xor    %edi,%edi
  800c56:	89 c3                	mov    %eax,%ebx
  800c58:	89 d8                	mov    %ebx,%eax
  800c5a:	89 fa                	mov    %edi,%edx
  800c5c:	83 c4 1c             	add    $0x1c,%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    
  800c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c68:	39 ce                	cmp    %ecx,%esi
  800c6a:	72 0c                	jb     800c78 <__udivdi3+0x118>
  800c6c:	31 db                	xor    %ebx,%ebx
  800c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c72:	0f 87 34 ff ff ff    	ja     800bac <__udivdi3+0x4c>
  800c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c7d:	e9 2a ff ff ff       	jmp    800bac <__udivdi3+0x4c>
  800c82:	66 90                	xchg   %ax,%ax
  800c84:	66 90                	xchg   %ax,%ax
  800c86:	66 90                	xchg   %ax,%ax
  800c88:	66 90                	xchg   %ax,%ax
  800c8a:	66 90                	xchg   %ax,%ax
  800c8c:	66 90                	xchg   %ax,%ax
  800c8e:	66 90                	xchg   %ax,%ax

00800c90 <__umoddi3>:
  800c90:	55                   	push   %ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 1c             	sub    $0x1c,%esp
  800c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ca7:	85 d2                	test   %edx,%edx
  800ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	89 3c 24             	mov    %edi,(%esp)
  800cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cba:	75 1c                	jne    800cd8 <__umoddi3+0x48>
  800cbc:	39 f7                	cmp    %esi,%edi
  800cbe:	76 50                	jbe    800d10 <__umoddi3+0x80>
  800cc0:	89 c8                	mov    %ecx,%eax
  800cc2:	89 f2                	mov    %esi,%edx
  800cc4:	f7 f7                	div    %edi
  800cc6:	89 d0                	mov    %edx,%eax
  800cc8:	31 d2                	xor    %edx,%edx
  800cca:	83 c4 1c             	add    $0x1c,%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
  800cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cd8:	39 f2                	cmp    %esi,%edx
  800cda:	89 d0                	mov    %edx,%eax
  800cdc:	77 52                	ja     800d30 <__umoddi3+0xa0>
  800cde:	0f bd ea             	bsr    %edx,%ebp
  800ce1:	83 f5 1f             	xor    $0x1f,%ebp
  800ce4:	75 5a                	jne    800d40 <__umoddi3+0xb0>
  800ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cea:	0f 82 e0 00 00 00    	jb     800dd0 <__umoddi3+0x140>
  800cf0:	39 0c 24             	cmp    %ecx,(%esp)
  800cf3:	0f 86 d7 00 00 00    	jbe    800dd0 <__umoddi3+0x140>
  800cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d01:	83 c4 1c             	add    $0x1c,%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    
  800d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d10:	85 ff                	test   %edi,%edi
  800d12:	89 fd                	mov    %edi,%ebp
  800d14:	75 0b                	jne    800d21 <__umoddi3+0x91>
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	f7 f7                	div    %edi
  800d1f:	89 c5                	mov    %eax,%ebp
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	31 d2                	xor    %edx,%edx
  800d25:	f7 f5                	div    %ebp
  800d27:	89 c8                	mov    %ecx,%eax
  800d29:	f7 f5                	div    %ebp
  800d2b:	89 d0                	mov    %edx,%eax
  800d2d:	eb 99                	jmp    800cc8 <__umoddi3+0x38>
  800d2f:	90                   	nop
  800d30:	89 c8                	mov    %ecx,%eax
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	83 c4 1c             	add    $0x1c,%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
  800d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d40:	8b 34 24             	mov    (%esp),%esi
  800d43:	bf 20 00 00 00       	mov    $0x20,%edi
  800d48:	89 e9                	mov    %ebp,%ecx
  800d4a:	29 ef                	sub    %ebp,%edi
  800d4c:	d3 e0                	shl    %cl,%eax
  800d4e:	89 f9                	mov    %edi,%ecx
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	d3 ea                	shr    %cl,%edx
  800d54:	89 e9                	mov    %ebp,%ecx
  800d56:	09 c2                	or     %eax,%edx
  800d58:	89 d8                	mov    %ebx,%eax
  800d5a:	89 14 24             	mov    %edx,(%esp)
  800d5d:	89 f2                	mov    %esi,%edx
  800d5f:	d3 e2                	shl    %cl,%edx
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d6b:	d3 e8                	shr    %cl,%eax
  800d6d:	89 e9                	mov    %ebp,%ecx
  800d6f:	89 c6                	mov    %eax,%esi
  800d71:	d3 e3                	shl    %cl,%ebx
  800d73:	89 f9                	mov    %edi,%ecx
  800d75:	89 d0                	mov    %edx,%eax
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	89 e9                	mov    %ebp,%ecx
  800d7b:	09 d8                	or     %ebx,%eax
  800d7d:	89 d3                	mov    %edx,%ebx
  800d7f:	89 f2                	mov    %esi,%edx
  800d81:	f7 34 24             	divl   (%esp)
  800d84:	89 d6                	mov    %edx,%esi
  800d86:	d3 e3                	shl    %cl,%ebx
  800d88:	f7 64 24 04          	mull   0x4(%esp)
  800d8c:	39 d6                	cmp    %edx,%esi
  800d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d92:	89 d1                	mov    %edx,%ecx
  800d94:	89 c3                	mov    %eax,%ebx
  800d96:	72 08                	jb     800da0 <__umoddi3+0x110>
  800d98:	75 11                	jne    800dab <__umoddi3+0x11b>
  800d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d9e:	73 0b                	jae    800dab <__umoddi3+0x11b>
  800da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800da4:	1b 14 24             	sbb    (%esp),%edx
  800da7:	89 d1                	mov    %edx,%ecx
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  800daf:	29 da                	sub    %ebx,%edx
  800db1:	19 ce                	sbb    %ecx,%esi
  800db3:	89 f9                	mov    %edi,%ecx
  800db5:	89 f0                	mov    %esi,%eax
  800db7:	d3 e0                	shl    %cl,%eax
  800db9:	89 e9                	mov    %ebp,%ecx
  800dbb:	d3 ea                	shr    %cl,%edx
  800dbd:	89 e9                	mov    %ebp,%ecx
  800dbf:	d3 ee                	shr    %cl,%esi
  800dc1:	09 d0                	or     %edx,%eax
  800dc3:	89 f2                	mov    %esi,%edx
  800dc5:	83 c4 1c             	add    $0x1c,%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    
  800dcd:	8d 76 00             	lea    0x0(%esi),%esi
  800dd0:	29 f9                	sub    %edi,%ecx
  800dd2:	19 d6                	sbb    %edx,%esi
  800dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ddc:	e9 18 ff ff ff       	jmp    800cf9 <__umoddi3+0x69>
