<# ::
@echo off
setlocal enableDelayedExpansion

:: Tasti di controllo
set "KEY_TOGGLE=V"
set "KEY_DISABLE=Delete"
set "KEY_HIDE=Home"

set logocolor=[38;5;92m
set "lastinput="

title %nothing%
set /a totalProfiles=0
goto init

:init
:: Elenco profili disponibili
call :makeProfile "RandomClick" "Riproduce casualmente i tuoi pattern registrati" "0" ""
call :makeProfile "SineA" "Randomization using Sine Waves (Experimental)" "2" "13 15"
call :makeProfile "BasicA" "Basic randomization (NOT RECOMMENDED)" "2" "10 12"
call :makeProfile "BasicB" "Basic randomization (NOT RECOMMENDED)" "2" "18 20"
call :makeProfile "OldVoidA" "Void v1.4.2 randomization" "2" "12 14"
call :makeProfile "OldVoidB" "Void v1.4.2 randomization" "2" "17 19"
call :makeProfile "ClickPlayer" "Riproduce un file di click" "1" "clicks.txt"
goto list

:banner
cls
echo %logocolor% __   __   _    _ 
echo \ \ / /__(_)__^| ^|
echo  \ V / _ \ / _` ^|
echo   \_/\___/_\__,_^| [0mlite 1.0
echo.
goto :eof

:list
call :banner
echo Num  Profile[31GDescription
echo ==================================================
for /l %%a in (1,1,%totalProfiles%) do (
	echo %%a.[6G!profile[%%a]![31G!profile[%%a]_desc! [!profile[%%a]_defaultargs!]
)
echo.
goto main

:main
set /p "input=[?25h> "
if "%input%"=="%lastinput%" goto main
set "lastinput=%input%"

set /a counter=0
for %%a in (%input%) do (
	set "input[!counter!]=%%a"
	set /a counter+=1
)
set /a counter-=1

if not defined profile[!input[0]!] (
	echo '!input[0]!' is not a valid profile.
	goto main
)

set "profile=profile[!input[0]!]"
if %counter%==0 (
	call :start "!%profile%!" "!%profile%_defaultargs!"
) else if %counter% GEQ !%profile%_totalargs! (
	set "providedargs="
	for /l %%a in (1,1,!%profile%_totalargs!) do (
		if %%a==1 (set "providedargs=!input[%%a]!") else (set "providedargs=!providedargs! !input[%%a]!")
	)
	call :start "!%profile%!" "!providedargs!"
) else (
	echo Profile '!%profile%!' requires !%profile%_totalargs! arguments.
)
goto main

:makeProfile
set /a totalProfiles+=1
set "profile[!totalProfiles!]=%~1"
set "profile[!totalProfiles!]_desc=%~2"
set "profile[!totalProfiles!]_totalargs=%~3"
set "profile[!totalProfiles!]_defaultargs=%~4"

set "profile[%~1]=%~1"
set "profile[%~1]_desc=%~2"
set "profile[%~1]_totalargs=%~3"
set "profile[%~1]_defaultargs=%~4"

set "profile_%~1=!totalProfiles!"
goto :eof

:start
call :banner
echo Profile: %~1 [%~2]
call :run "%~1" "%KEY_TOGGLE% %KEY_HIDE% %KEY_DISABLE%" "%~2"
goto list

:run
set "lastinput="
setlocal
set "POWERSHELL_BAT_ARGS=%*"
if defined POWERSHELL_BAT_ARGS set "POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%"
endlocal & powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -Command "$_ = $input; Invoke-Expression $( '$input = $_; $_ = \"\"; $args = @( &{ $args } %POWERSHELL_BAT_ARGS% );' + [String]::Join( [char]10, $( Get-Content \"%~f0\" ) ) )"
if defined DEBUG pause
goto :EOF
#>
$namespace = get-random
$class = get-random

$code = @"
using System;
using System.IO;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Threading;
namespace n$namespace
{
	public class c$class
	{
    
        [DllImport("user32.dll")]
        private static extern short GetAsyncKeyState(System.Int32 vKey);
        [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
        private static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int GetWindowThreadProcessId(IntPtr handle, out int processId);
        [DllImport("user32.dll", SetLastError = true)]
        static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("user32.dll")]
        public static extern IntPtr SendMessage(IntPtr hWnd, uint wMsg, UIntPtr wParam, IntPtr lParam);
        [DllImport("kernel32.dll")]
        static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")]
        static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
		
		public static IntPtr MAKELPARAM(int p, int p_2)
		{
			return (IntPtr) ((p_2 << 16) | (p & 0xFFFF));
		}
		
		private static int GetKey(string s)
		{	
			return (int) Enum.Parse(typeof(ConsoleKey), s);
		}
		
		private static string GetKeyString(string s)
		{
			if (string.IsNullOrEmpty(s))
			{
				return string.Empty;
			}
			s = s.ToLower();
			s = char.ToUpper(s[0]) + s.Substring(1);
			return s;
		}
		
		private static long GetSystemTime()
		{
			return BitConverter.ToInt64(BitConverter.GetBytes(DateTimeOffset.Now.ToUnixTimeMilliseconds()), 0);
		}
		
		static Random rand;
		static string[] KeybindString = new string[3];
		static int[] Keybinds = new int[3];
		static bool ClickerEnabled;
		static bool WindowVisible;
		static int StatusRow;
		static IntPtr ConsoleWindow;
		static IntPtr ForegroundWindow;
		static IntPtr MCWindow;
		
		// ========== LISTA FISSA DEI TUOI FILE DI PATTERN ==========
		static readonly string[] ClickFiles = new string[] {
			@"C:\Users\Ernev\.ollama\cache\0cf80gx4v.txt",
			@"C:\Users\Ernev\.ollama\cache\6cp8iGx4v.txt",
			@"C:\Users\Ernev\.ollama\cache\7lT80gx4v.txt",
			@"C:\Users\Ernev\.ollama\cache\58ct54zx.txt",
			@"C:\Users\Ernev\.ollama\cache\59t54gx.txt",
			@"C:\Users\Ernev\.ollama\cache\59tct54zx.txt",
			@"C:\Users\Ernev\.ollama\cache\99t54gx.txt"
		};
		
		private static double GetRandomDouble(double minimum, double maximum)
		{
			return rand.NextDouble() * (maximum - minimum) + minimum;
		}
		
		public static void Init(string toggle, string hide, string disable) {
			KeybindString[0] = GetKeyString(toggle);
			KeybindString[1] = GetKeyString(hide);
			KeybindString[2] = GetKeyString(disable);
			Keybinds[0] = GetKey(KeybindString[0]);
			Keybinds[1] = GetKey(KeybindString[1]);
			Keybinds[2] = GetKey(KeybindString[2]);
			
			ClickerEnabled = true;
			WindowVisible = true;
			
			Console.WriteLine("");
			Console.WriteLine("Keybinds:");
			Console.WriteLine("  - Toggle Clicker: " + KeybindString[0]);
			Console.WriteLine("  - Hide/Show Window: " + KeybindString[1]);
			Console.WriteLine("  - Disable Clicker (Change Profile): " + KeybindString[2]);
			Console.WriteLine("");
		}
		
		public static void DrawStatus(int row, bool enabled)
		{
			Console.SetCursorPosition(1, row);
			Console.WriteLine("Status: " + (enabled ? "\x1b[92mEnabled \x1b[0m" : "\x1b[91mDisabled\x1b[0m"));
		}
		
		public static void DrawStatus(int row, bool enabled, string extra)
		{
			DrawStatus(row, enabled);
			Console.SetCursorPosition(1, row + 1);
			Console.Write(extra + "   ");
		}
		
		// KeyStates[0] = Left Mouse Button (non usato direttamente)
		static bool[] KeyStates = new bool[3];
		static bool[] PrevKeyStates = new bool[3];
		
		public static bool Binds() {
			bool ReturnValue = true;
			PrevKeyStates[0] = KeyStates[0];
			KeyStates[0] = BitConverter.GetBytes(GetAsyncKeyState(Keybinds[0]))[1] == 0x80;
			PrevKeyStates[1] = KeyStates[1];
			KeyStates[1] = BitConverter.GetBytes(GetAsyncKeyState(Keybinds[1]))[1] == 0x80;
			PrevKeyStates[2] = KeyStates[2];
			KeyStates[2] = BitConverter.GetBytes(GetAsyncKeyState(Keybinds[2]))[1] == 0x80;
			
			// Toggle Clicker
			if (PrevKeyStates[0] != KeyStates[0] && KeyStates[0])
			{
				ClickerEnabled = !ClickerEnabled;
				DrawStatus(StatusRow, ClickerEnabled);
			}
			
			// Hide/Show Window
			if (PrevKeyStates[1] != KeyStates[1] && KeyStates[1])
			{
				WindowVisible = !WindowVisible;
				ShowWindow(ConsoleWindow, WindowVisible ? 5 : 0);
			}
			
			// Disable Clicker (Change Profile)
			if (PrevKeyStates[2] != KeyStates[2] && KeyStates[2])
			{
				ClickerEnabled = false;
				DrawStatus(StatusRow, ClickerEnabled);
				if (!WindowVisible) ShowWindow(ConsoleWindow, 5);
				ReturnValue = false;
			}
			return ReturnValue;
		}

		// ##################################################
		// ##  PROFILO RANDOM CLICK (nuovo)               ##
		// ##################################################
		public static void RandomClick(string[] args)
		{
			bool running = true;
			StatusRow = Console.CursorTop;
			DrawStatus(StatusRow, ClickerEnabled);
			
			bool prevLmb = false;
			bool replaying = false;
			List<int> currentDelays = null;
			int delayIndex = 0;
			string currentFileName = "";
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (!Binds()) running = false;
				if (!running) break;
				
				bool lmbDown = (GetAsyncKeyState(1) & 0x8000) != 0;
				
				// Nuova pressione: scegli file casuale e carica
				if (lmbDown && !prevLmb && ClickerEnabled && !replaying)
				{
					string chosenFile = ClickFiles[rand.Next(ClickFiles.Length)];
					currentDelays = LoadDelays(chosenFile);
					if (currentDelays.Count > 20)
					{
						replaying = true;
						delayIndex = rand.Next(currentDelays.Count);
						currentFileName = Path.GetFileName(chosenFile);
						DrawStatus(StatusRow, ClickerEnabled, "Riproduco: " + currentFileName);
					}
					else
					{
						currentDelays = null;
					}
				}
				
				// Durante la pressione, se replaying è attivo, invia click
				if (replaying && lmbDown && currentDelays != null && currentDelays.Count > 0)
				{
					if (MCWindow == ForegroundWindow &&
					    SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero,
					        MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr)1)
					{
						SendMessage(ForegroundWindow, 0x0201, (UIntPtr)0x0001,
						    MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
						SendMessage(ForegroundWindow, 0x0202, UIntPtr.Zero,
						    MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
						
						int sleep = currentDelays[delayIndex];
						delayIndex = (delayIndex + 1) % currentDelays.Count;
						
						long target = GetSystemTime() + sleep;
						while (GetSystemTime() < target && (GetAsyncKeyState(1) & 0x8000) != 0 && running)
							Thread.Sleep(1);
					}
					else
					{
						Thread.Sleep(5);
					}
				}
				else
				{
					Thread.Sleep(5);
				}
				
				// Rilascio tasto: ferma replay
				if (!lmbDown && prevLmb)
				{
					replaying = false;
					currentDelays = null;
					DrawStatus(StatusRow, ClickerEnabled);
				}
				
				prevLmb = lmbDown;
				Thread.Sleep(1);
			}
		}

		// Carica una lista di ritardi da file (stesso formato di ClickPlayer)
		// Compatibile con C# 5 / PowerShell 5.1
		static List<int> LoadDelays(string file)
		{
			var list = new List<int>();
			if (!File.Exists(file))
			{
				Console.WriteLine("File non trovato: " + file);
				return list;
			}
			foreach (var line in File.ReadLines(file))
			{
				int ms;
				if (int.TryParse(line, out ms) && ms > 0)
					list.Add(ms);
			}
			return list;
		}
		
		// ##################################################
		// ##  PROFILI ORIGINALI (completi)               ##
		// ##################################################
		
		public static void Basic(string[] args)
		{
			bool running = true;
			StatusRow = Console.CursorTop;
			
			int MinimumCPS = Int32.Parse(args[4]);
			int MaximumCPS = Int32.Parse(args[5]);
			if (MinimumCPS > MaximumCPS)
			{
				Console.WriteLine("Minimum CPS cannot be over Maximum CPS");
				return;
			}
			DrawStatus(StatusRow, ClickerEnabled);
			
			bool ButtonUpOrDown = false; // false = down, true = up
			long ClickWaitTill = 0;
			long RightNow = GetSystemTime();
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(1))[1] == 0x80)
					{
						if (MCWindow == ForegroundWindow)
						{
							if (SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr) 1)
							{
								RightNow = GetSystemTime();
								if (RightNow >= ClickWaitTill)
								{
									if (ButtonUpOrDown) SendMessage(ForegroundWindow, 0x0202, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									else SendMessage(ForegroundWindow, 0x0201, (UIntPtr) 0x0001, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									ButtonUpOrDown = !ButtonUpOrDown;
									
									int SleepTime = rand.Next((500 / MaximumCPS), (500 / MinimumCPS));
									ClickWaitTill = RightNow + SleepTime;
								}
							}
						}
					}
					else ButtonUpOrDown = false;
				}
				
				if (!Binds()) running = false;
			}
			return;
		}
		
		public static void OldVoid(string[] args)
		{
			bool running = true;
			StatusRow = Console.CursorTop;
			
			int MinimumCPS = Int32.Parse(args[4]);
			int MaximumCPS = Int32.Parse(args[5]);
			if (MinimumCPS > MaximumCPS)
			{
				Console.WriteLine("Minimum CPS cannot be over Maximum CPS");
				return;
			}
			DrawStatus(StatusRow, ClickerEnabled);
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(1))[1] == 0x80)
					{
						if (MCWindow == ForegroundWindow)
						{
							if (SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr) 1)
							{
								if (rand.Next(1, 6) == 2)
								{
									if (rand.Next(1, 6) <= 2) Thread.Sleep(rand.Next((1000 / MaximumCPS), (1000 / MinimumCPS)) - (rand.Next(8, 32)) >> 1);
									else Thread.Sleep(rand.Next((1000 / MaximumCPS), (1000 / MinimumCPS)) >> 1);
								}
								else
								{
									SendMessage((IntPtr) ForegroundWindow, 0x0201, (UIntPtr) 0x0001, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									
									if (rand.Next(1, 6) <= 2) Thread.Sleep(rand.Next((1000 / MaximumCPS), (1000 / MinimumCPS)) - (rand.Next(8, 32)) >> 1);
									else Thread.Sleep(rand.Next((1000 / MaximumCPS), (1000 / MinimumCPS)) >> 1);
										
									SendMessage((IntPtr) ForegroundWindow, 0x0202, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									
									if (rand.Next(1, 6) <= 2) Thread.Sleep(rand.Next((1000 / MaximumCPS), (1000 / MinimumCPS)) - (rand.Next(8, 32)) >> 1);
									else Thread.Sleep(rand.Next((1000 / MaximumCPS), (1000 / MinimumCPS)) >> 1);
								}
							}
						}
					}
				}
				
				if (!Binds()) running = false;
			}
			return;
		}
		
		public static void Jitter(string[] args) {
			bool running = true;
			StatusRow = Console.CursorTop;
			
			int MinimumCPS = Int32.Parse(args[4]);
			int MaximumCPS = Int32.Parse(args[5]);
			if (MinimumCPS > MaximumCPS)
			{
				Console.WriteLine("Minimum CPS cannot be over Maximum CPS");
				return;
			}
			DrawStatus(StatusRow, ClickerEnabled);
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(1))[1] == 0x80)
					{
						if (MCWindow == ForegroundWindow)
						{
							if (SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr) 1)
							{
								int SleepTime = rand.Next((500 / MaximumCPS), (500 / MinimumCPS));
								SendMessage(ForegroundWindow, 0x0201, (UIntPtr) 0x0001, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
								Thread.Sleep(SleepTime);
								SendMessage(ForegroundWindow, 0x0202, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
								Thread.Sleep(SleepTime);
							}
						}
					}
				}
				
				if (!Binds()) running = false;
			}
			return;
		}
		
		public static void Butterfly(string[] args) {
			bool running = true;
			StatusRow = Console.CursorTop;
			
			int MinimumCPS = Int32.Parse(args[4]);
			int MaximumCPS = Int32.Parse(args[5]);
			if (MinimumCPS > MaximumCPS)
			{
				Console.WriteLine("Minimum CPS cannot be over Maximum CPS");
				return;
			}
			DrawStatus(StatusRow, ClickerEnabled);
			
			bool ButtonUpOrDown = false; // false = down, true = up
			long ClickWaitTill = 0;
			long RightNow = GetSystemTime();
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(1))[1] == 0x80)
					{
						if (MCWindow == ForegroundWindow)
						{
							if (SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr) 1)
							{
								RightNow = GetSystemTime();
								if (RightNow >= ClickWaitTill)
								{
									if (ButtonUpOrDown) SendMessage(ForegroundWindow, 0x0202, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									else SendMessage(ForegroundWindow, 0x0201, (UIntPtr) 0x0001, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									ButtonUpOrDown = !ButtonUpOrDown;
									
									int SleepTime = rand.Next((500 / MaximumCPS), (500 / MinimumCPS));
									ClickWaitTill = RightNow + SleepTime;
								}
							}
						}
					}
					else ButtonUpOrDown = false;
				}
				
				if (!Binds()) running = false;
			}
			return;
		}
		
		public static void Sine(string[] args) {
			bool running = true;
			StatusRow = Console.CursorTop;
			
			int MinimumCPS = Int32.Parse(args[4]);
			int MaximumCPS = Int32.Parse(args[5]);
			if (MinimumCPS > MaximumCPS)
			{
				Console.WriteLine("Minimum CPS cannot be over Maximum CPS");
				return;
			}
			
			long lastLoopRun = 0;
			long now = 0;
			long dif = 0;
			long lastDelay = 0;
			
			long cpsSpike = 0;
			long cpsDrop = 0;
			long lastEvent = -15;
			double sinX = 0;
			
			DrawStatus(StatusRow, ClickerEnabled);
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(1))[1] == 0x80)
					{
						if (MCWindow == ForegroundWindow)
						{
							if (lastLoopRun == 0) {
								lastLoopRun = GetSystemTime();
							} else {
								now = GetSystemTime();
								dif = (now - lastLoopRun) >> 1;
								dif -= lastDelay;
								lastLoopRun = now;
								
								if (cpsDrop > 0) cpsDrop--;
								if (cpsSpike > 0) cpsSpike--;
								
								if (lastEvent > 0) {
									if (rand.Next(0, 100 / (int) lastEvent) == 0) {
										cpsSpike = 25;
										lastEvent = -20;
									} else if (rand.Next(0, 100 / (int) lastEvent) == 0) {
										cpsDrop = 50;
										lastEvent = -30;
									}
								}
								
								double minDelay = 1000 / MinimumCPS;
								if (cpsSpike > 0)
									minDelay -= GetRandomDouble(1, 15);
								double maxDelay = 1000 / MaximumCPS;
								if (cpsDrop > 0)
									maxDelay += GetRandomDouble(1, 15);
								double average = (maxDelay + minDelay) / 2;
								double halfDifference = (minDelay - maxDelay) / 2;
								double delay = Math.Sin(sinX) * halfDifference + average;
								sinX += GetRandomDouble(GetRandomDouble(0.03, 0.1), GetRandomDouble(0.69, 1.24));
								
								if (SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr) 1)
								{
									lastDelay = (((int)delay) >> 1) - dif;
									if (lastDelay < 0 || lastDelay == Int32.MaxValue) lastDelay = 0;
									SendMessage(ForegroundWindow, 0x0201, (UIntPtr) 0x0001, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									Thread.Sleep((int) lastDelay);
									SendMessage(ForegroundWindow, 0x0202, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									Thread.Sleep((int) lastDelay);
								}
								lastEvent++;
							}
						}
					}
				}
				
				if (!Binds()) running = false;
			}
			return;
		}
		
		public static void ClickPlayer(string[] args) {
			bool running = true;
			List<int> ClickTimes = new List<int>();
			
			StatusRow = Console.CursorTop;
			
			if (File.Exists(args[4]))
			{
				using (StreamReader sr = File.OpenText(args[4]))
				{
					string s;
					while ((s = sr.ReadLine()) != null)
					{
						try
						{
							int num = Int32.Parse(s);
							if (num > 0)
								ClickTimes.Add(num);
						}
						catch (FormatException)
						{
							Console.WriteLine("Cannot parse '{0}'", s);
						}
					}
				}
			}
			else
			{
				Console.WriteLine("There was an error loading '{0}'.", args[4]);
				return;
			}
			
			if (ClickTimes.Count < 50)
			{
				Console.WriteLine("Too few click times in '{0}'.", args[4]);
				return;
			}
			
			bool ChangeStartingPoint = false;
			int ClickingPoint = rand.Next(1, ClickTimes.Count / 4);
			long ClickWaitTill = 0;
			long RightNow = GetSystemTime();
			
			DrawStatus(StatusRow, ClickerEnabled, "Starting Point: " + ClickingPoint);
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(1))[1] == 0x80)
					{
						if (MCWindow == ForegroundWindow)
						{
							if (SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr) 1)
							{
								RightNow = GetSystemTime();
								ChangeStartingPoint = true;
								if (RightNow >= ClickWaitTill)
								{
									SendMessage(ForegroundWindow, 0x0201, (UIntPtr) 0x0001, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									SendMessage(ForegroundWindow, 0x0202, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									
									if (ClickingPoint == ClickTimes.Count - 1)
										ClickingPoint = rand.Next(1, ClickTimes.Count / 4);
									else
										ClickingPoint += 1;
									
									ClickWaitTill = RightNow + ClickTimes[ClickingPoint];
								}
							}
						}
					}
					else if (ChangeStartingPoint)
					{
						ChangeStartingPoint = false;
						ClickingPoint = rand.Next(1, ClickTimes.Count / 4);
						DrawStatus(StatusRow, ClickerEnabled, "Starting Point: " + ClickingPoint);
						ClickWaitTill = 0;
						Thread.Sleep(1);
					}
					else
					{
						Thread.Sleep(1);
					}
				}
				
				if (!Binds()) running = false;
			}
			return;
		}

	    public static void Main()
		{
			rand = new Random();
			ConsoleWindow = GetConsoleWindow();
			string arg="$args";
			string[] args = arg.Split(' ');
			string profile = args[0];
			
			Init(args[1], args[2], args[3]);
			
			if (profile.Contains("RandomClick"))
			{
				RandomClick(args);
			}
			else if (profile.Contains("ClickPlayer"))
			{
				ClickPlayer(args);
			}
			else if (profile.Contains("Sine"))
			{
				Sine(args);
			}
			else if (profile.Contains("Basic"))
			{
				Basic(args);
			}
			else if (profile.Contains("OldVoid"))
			{
				OldVoid(args);
			}
			else if (profile.Contains("Jitter"))
			{
				Jitter(args);
			}
			else if (profile.Contains("Butterfly"))
			{
				Butterfly(args);
			}
			else
			{
				Console.WriteLine("There was an error loading your profile, please contact 'exro#4981' on Discord if this problem persists");
			}
	    }
    }
}
"@

$assemblies = ("System.Windows.Forms","System.Drawing")
Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $code -Language CSharp
iex "[n$namespace.c$class]::Main()"
