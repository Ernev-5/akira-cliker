<# ::
@echo off

set "DEBUG=true"

::https://learn.microsoft.com/en-us/dotnet/api/system.consolekey
:: The key that is used to toggle the click on and off
set "KEY_TOGGLE=Oem5"
:: The key that is used to disable the clicker after it has started to change profile
set "KEY_DISABLE=Delete"
:: The key that is used to hide the clicker window after it has started
set "KEY_HIDE=Home"

set "lastinput="

title %nothing%
setlocal enableDelayedExpansion
set /a totalProfiles=0
goto init

:init
rem These profiles are disabled because they are unfinshed
::call :makeProfile "JitterA" "Jitter simulation" "2" "10 13"
::call :makeProfile "ButterflyA" "Butterfly simulation" "2" "14 17"
::call :makeProfile "ButterflyB" "Butterfly simulation" "2" "17 22"
call :makeProfile "OldVoidA" "Void v1.4.2 randomization" "2" "12 14"
call :makeProfile "OldVoidB" "Void v1.4.2 randomization" "2" "17 19"
call :makeProfile "SineA" "Randomization using Sine Waves (Experimental)" "2" "13 15"
call :makeProfile "BasicA" "Basic randomization (NOT RECOMMENDED)" "2" "10 12"
call :makeProfile "BasicB" "Basic randomization (NOT RECOMMENDED)" "2" "18 20"
call :makeProfile "ClickPlayer" "Click player (Multi-Profile Random)" "1" "MULTI"
goto list

:banner
cls
echo [?25l%logocolor% __   __   _    _ 
echo  \ \ / /__(_)__^| ^|
echo   \ V / _ \ / _` ^|
echo    \_/\___/_\__,_^| [0mlite 1.0
echo.
goto :eof

:list
call :banner

echo Num  Profile     Description
echo ==================================================
for /l %%a in (1,1,%totalProfiles%) do (
	echo %%a. !profile[%%a]! - !profile[%%a]_desc! [!profile[%%a]_defaultargs!]
)
echo.
goto main

:main
set /p "input=> "
if "%input%"=="%lastinput%" goto main
set "lastinput=%input%"

:: input system recode here
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

:: call :start <profile> <args>
:start
call :banner
echo Profile: %~1 [%~2]
call :run "%~1" "%KEY_TOGGLE% %KEY_HIDE% %KEY_DISABLE%" "%~2"
goto list

:: @makeProfile <name> <description> <total-args> <default-args>
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
			if (s == "\\" || s.ToLower() == "backslash") return (int)ConsoleKey.Oem5;
			return (int) Enum.Parse(typeof(ConsoleKey), s);
		}
		
		private static string GetKeyString(string s)
		{
			if (string.IsNullOrEmpty(s))
			{
				return string.Empty;
			}
			if (s.Equals("Oem5", StringComparison.OrdinalIgnoreCase)) return "\\";
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
		
		private static double GetRandomDouble(double minimum, double maximum)
		{
			return rand.NextDouble() * (maximum - minimum) + minimum;
		}
		
		public static void Init(string toggle, string hide, string disable) {
			KeybindString[0] = GetKeyString(toggle);
			KeybindString[1] = GetKeyString(hide);
			KeybindString[2] = GetKeyString(disable);
			
			Keybinds[0] = GetKey(toggle);
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
			Console.WriteLine("Status: " + (enabled ? "Enabled " : "Disabled"));
		}
		
		public static void DrawStatus(int row, bool enabled, string label, string value)
		{
			Console.SetCursorPosition(1, row);
			Console.WriteLine("Status: " + (enabled ? "Enabled " : "Disabled"));
			Console.SetCursorPosition(1, row + 1);
			Console.WriteLine(label + ": " + value + "    ");
		}
		
		public static void DrawStatus(int row, bool enabled, string label, int value)
		{
			Console.SetCursorPosition(1, row);
			Console.WriteLine("Status: " + (enabled ? "Enabled " : "Disabled"));
			Console.SetCursorPosition(1, row + 1);
			Console.WriteLine(label + ": " + value + "    ");
		}
		
		public static bool MinOverMaxCheck(int min, int max)
		{
			if (min > max)
			{
				Console.WriteLine("Minimum CPS cannot be over Maximum CPS");
				return true;
			}
			return false;
		}
		
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
			
			if (PrevKeyStates[0] != KeyStates[0] && KeyStates[0])
			{
				ClickerEnabled = !ClickerEnabled;
				DrawStatus(StatusRow, ClickerEnabled);
			}
			
			if (PrevKeyStates[1] != KeyStates[1] && KeyStates[1])
			{
				WindowVisible = !WindowVisible;
				ShowWindow(ConsoleWindow, WindowVisible ? 5 : 0);
			}
			
			if (PrevKeyStates[2] != KeyStates[2] && KeyStates[2])
			{
				ClickerEnabled = false;
				DrawStatus(StatusRow, ClickerEnabled);
				if (!WindowVisible) ShowWindow(ConsoleWindow, 5);
				ReturnValue = false;
			}
			return ReturnValue;
		}
		
		public static void Basic(string[] args)
		{
			bool running = true;
			StatusRow = Console.CursorTop;
			
			int MinimumCPS = Int32.Parse(args[4]);
			int MaximumCPS = Int32.Parse(args[5]);
			if (MinOverMaxCheck(MinimumCPS, MaximumCPS)) return;
			DrawStatus(StatusRow, ClickerEnabled);
			
			bool ButtonUpOrDown = false;
			long ClickWaitTill = 0;
			long RightNow = GetSystemTime();
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(6))[1] == 0x80)
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
			if (MinOverMaxCheck(MinimumCPS, MaximumCPS)) return;
			DrawStatus(StatusRow, ClickerEnabled);
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(6))[1] == 0x80)
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
			if (MinOverMaxCheck(MinimumCPS, MaximumCPS)) return;
			DrawStatus(StatusRow, ClickerEnabled);
			
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(6))[1] == 0x80)
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
			if (MinOverMaxCheck(MinimumCPS, MaximumCPS)) return;
			DrawStatus(StatusRow, ClickerEnabled);
			
			bool ButtonUpOrDown = false;
			long ClickWaitTill = 0;
			long RightNow = GetSystemTime();
			while (running)
			{
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				
				if (ClickerEnabled)
				{
					if (BitConverter.GetBytes(GetAsyncKeyState(6))[1] == 0x80)
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
			if (MinOverMaxCheck(MinimumCPS, MaximumCPS)) return;
			
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
					if (BitConverter.GetBytes(GetAsyncKeyState(6))[1] == 0x80)
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
			StatusRow = Console.CursorTop;
			// Lista dei file di configurazione specificati
			string[] configFiles = new string[] {
				@"C:\Users\Ernev\.ollama\cache\0cf80gx4v.txt",
				@"C:\Users\Ernev\.ollama\cache\6cp8iGx4v.txt",
				@"C:\Users\Ernev\.ollama\cache\7lT80gx4v.txt",
				@"C:\Users\Ernev\.ollama\cache\58ct54zx.txt",
				@"C:\Users\Ernev\.ollama\cache\59t54gx.txt",
				@"C:\Users\Ernev\.ollama\cache\59tct54zx.txt",
				@"C:\Users\Ernev\.ollama\cache\99t54gx.txt"
			};
			// Struttura per contenere tutti i profili caricati in RAM
			List<List<int>> LoadedProfiles = new List<List<int>>();
			foreach (string path in configFiles) {
				if (File.Exists(path)) {
					List<int> currentList = new List<int>();
					using (StreamReader sr = File.OpenText(path)) {
						string s;
						while ((s = sr.ReadLine()) != null) {
							int num;
							if (Int32.TryParse(s, out num) && num > 0) {
								currentList.Add(num);
							}
						}
					}
					if (currentList.Count >= 50) {
						LoadedProfiles.Add(currentList);
					}
				}
			}

			if (LoadedProfiles.Count == 0) {
				Console.WriteLine("Errore: Nessun file di configurazione valido trovato o caricato.");
				return;
			}

			Console.WriteLine("Caricati con successo " + LoadedProfiles.Count + " profili in RAM.");

			bool ChangeStartingPoint = false;
			int currentProfileIndex = rand.Next(0, LoadedProfiles.Count);
			List<int> ActiveProfile = LoadedProfiles[currentProfileIndex];
			int ClickingPoint = rand.Next(1, ActiveProfile.Count / 4);
			long ClickWaitTill = 0;
			long RightNow = GetSystemTime();
			DrawStatus(StatusRow, ClickerEnabled, "Profilo Attivo", currentProfileIndex + 1);

			while (running) {
				ForegroundWindow = GetForegroundWindow();
				MCWindow = FindWindow("LWJGL", null);
				if (ClickerEnabled) {
					if (BitConverter.GetBytes(GetAsyncKeyState(6))[1] == 0x80) {
						if (MCWindow == ForegroundWindow) {
							if (SendMessage(ForegroundWindow, 0x0084, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y)) == (IntPtr)1) {
								RightNow = GetSystemTime();
								// Se e una nuova pressione, seleziona una nuova registrazione a caso
								if (!ChangeStartingPoint) {
									ChangeStartingPoint = true;
									currentProfileIndex = rand.Next(0, LoadedProfiles.Count);
									ActiveProfile = LoadedProfiles[currentProfileIndex];
									ClickingPoint = rand.Next(1, ActiveProfile.Count / 4);
									DrawStatus(StatusRow, ClickerEnabled, "Profilo Attivo", currentProfileIndex + 1);
								}

								if (RightNow >= ClickWaitTill) {
									SendMessage(ForegroundWindow, 0x0201, (UIntPtr)0x0001, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									SendMessage(ForegroundWindow, 0x0202, UIntPtr.Zero, MAKELPARAM(Cursor.Position.X, Cursor.Position.Y));
									if (ClickingPoint >= ActiveProfile.Count - 1)
										ClickingPoint = rand.Next(1, ActiveProfile.Count / 4);
									else
										ClickingPoint += 1;

									ClickWaitTill = RightNow + ActiveProfile[ClickingPoint];
								}
							}
						}
					} else if (ChangeStartingPoint) {
						// Reset al rilascio del tasto per preparare la rotazione successiva
						ChangeStartingPoint = false;
						ClickWaitTill = 0;
						Thread.Sleep(1);
					} else {
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
			
			if (profile.Contains("Basic"))
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
			else if (profile.Contains("Sine"))
			{
				Sine(args);
			}
			else if (profile.Contains("ClickPlayer"))
			{
				ClickPlayer(args);
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