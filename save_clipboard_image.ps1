Add-Type -AssemblyName System.Windows.Forms

Add-Type -AssemblyName System.Drawing

 

if ([Windows.Forms.Clipboard]::ContainsImage()) {

    $img = [Windows.Forms.Clipboard]::GetImage()

    $file = $args[0]

    $img.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)

    Write-Output "1"

}
