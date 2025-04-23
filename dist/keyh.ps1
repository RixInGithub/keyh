Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
	[DllImport("user32.dll")]
	public static extern IntPtr GetForegroundWindow();
	[DllImport("user32.dll")]
	public static extern bool SetForegroundWindow(IntPtr hWnd);
	[DllImport("user32.dll")]
	public static extern IntPtr SetWindowLongPtr(IntPtr hWnd, int nIndex, IntPtr dwNewLong);
	[DllImport("user32.dll")]
	public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
	[DllImport("user32.dll", SetLastError=true)]
	public static extern IntPtr GetWindowLongPtr(IntPtr hWnd, int nIndex);
}
"@

$wpfBrushToJrawBrush = {
	param ($wpf)
	$col = $wpf.Color
	return [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($col.A, $col.R, $col.G, $col.B))
}

$x = New-Object System.Xml.XmlNodeReader([xml]@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="keyh!" Width="214" Height="118">
	<Grid>
		<Button Name="lck" Content="hS LOCK" Margin="7.5" Padding="10 15" HorizontalAlignment="Left" VerticalAlignment="Top" Cursor="Hand" FontSize="24"/>
		<Button Name="btn" Content="h" Margin="7.5" Padding="24 15" HorizontalAlignment="Right" VerticalAlignment="Top" Cursor="Hand" FontSize="24"/>
		<StackPanel Name="lht" Margin="11.25" Width="11" Height="11" HorizontalAlignment="Left" VerticalAlignment="Top" Cursor="Hand"/>
	</Grid>
</Window>
"@)
$icnPath="$env:Temp\keyh.png"
$win=[Windows.Markup.XamlReader]::Load($x)
$win.ResizeMode=[System.Windows.ResizeMode]::NoResize
$win.Topmost=1
$global:on = 0 # whether hs lock is on...
$helper = New-Object System.Diagnostics.Process
$helper.StartInfo=({
	$start=[System.Diagnostics.ProcessStartInfo]::new()
	$start.FileName="./helper.exe"
	$start.UseShellExecute=0
	$start.RedirectStandardInput=1
	$start.RedirectStandardOutput=1
	$start.CreateNoWindow=1
	return $start
}).Invoke()[0]
$helper.Start()|Out-Null
$global:hStdin=[System.IO.StreamWriter]::new($helper.StandardInput.BaseStream)

$lck = $win.FindName("lck")
$global:btn = $win.FindName("btn")
$lck.Add_Click({
	$global:on=-not$global:on
	Write-Host $global:on
	if($global:on){
		Write-Host "h?"
		$col = $global:btn.Background.Color
		$win.FindName("lht").Background=[System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromArgb($col.A,255-$col.R,255-$col.G,255-$col.B))
		return
	}
	$win.FindName("lht").Background=New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(0,1,1,1))
})

$global:btn.Add_Click({
	$global:hStdin.BaseStream.WriteByte(48+$global:on)
	$global:hStdin.Flush()
	$global:hStdin.BaseStream.Flush()
})

$win.Add_ContentRendered({$win.FindName("lht").IsHitTestVisible=0})
$win.Add_Closed({[System.Windows.Threading.Dispatcher]::ExitAllFrames()})

$win.Opacity=0
$win.Show()
$win.Opacity=1
# icon!
$size=4
$bmp = [System.Drawing.Bitmap]::new(16*$size,16*$size)
$jraw = [System.Drawing.Graphics]::FromImage($bmp) # hehehaha i love memeing on the jif ppl
$jraw.Clear(($wpfBrushToJrawBrush.Invoke($btn.BorderBrush))[0].Color)
$rect = [System.Drawing.Rectangle]::new(1*$size,1*$size,14*$size,14*$size)
$jraw.FillRectangle(($wpfBrushToJrawBrush.Invoke($btn.Background))[0], $rect)
$fg = ($wpfBrushToJrawBrush.Invoke($btn.Foreground))[0]
$rect = [System.Drawing.Rectangle]::new(5*$size,4*$size,2*$size,8*$size)
$jraw.FillRectangle($fg, $rect)
$rect = [System.Drawing.Rectangle]::new(7*$size,8*$size,3*$size,2*$size)
$jraw.FillRectangle($fg, $rect)
$rect = [System.Drawing.Rectangle]::new(9*$size,9*$size,2*$size,3*$size)
$jraw.FillRectangle($fg, $rect)
$bmp.Save($icnPath,[System.Drawing.Imaging.ImageFormat]::Png) # i used png in plant clicker too. so?
$jraw.Dispose()
$bmp.Dispose()
$bmp=$null
$jraw=$null
# icon!
$win.Icon=$icnPath
$hWnd=[System.Windows.Interop.WindowInteropHelper]::new($win).Handle
[User32]::SetWindowLongPtr($hWnd,-20,[IntPtr](([User32]::GetWindowLongPtr($hWnd,-20)).ToInt64()-bor(134217728))) | Out-Null
[User32]::ShowWindow($hWnd,4)|Out-Null
[System.Windows.Threading.Dispatcher]::Run()
Stop-Process -Id $helper.Id
$w=$null
$win.Icon=$null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
Remove-Item -Path $icnPath -Force