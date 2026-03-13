B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
'#Event: ExampleEvent (Value As Int)
'#DesignerProperty: Key: BooleanExample, DisplayName: Boolean Example, FieldType: Boolean, DefaultValue: True, Description: Example of a boolean property.
#DesignerProperty: Key: Value, DisplayName: Start Value, FieldType: Int, DefaultValue: 10, MinRange: 0, MaxRange: 100, Description: Start value
'#DesignerProperty: Key: StringWithListExample, DisplayName: String With List, FieldType: String, DefaultValue: Sunday, List: Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday
'#DesignerProperty: Key: StringExample, DisplayName: String Example, FieldType: String, DefaultValue: Text
#DesignerProperty: Key: ThermColor, DisplayName: Thermometer Color, FieldType: Color, DefaultValue: 0xFFDC143C, Description: Thermometer color
#DesignerProperty: Key: BackColor, DisplayName: Background Color, FieldType: Color, DefaultValue: 0xFF000000, Description: Background color

Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Public mBase As B4XView
	
	Private xui As XUI 'ignore
	Public Tag As Object
	
	Private cvs As B4XCanvas
	Private ThermColor As Int
	Private BackColor As Int
	Private mValue As Float = 0
	Private mMin As Float = 0
	Private mMax As Float = 100
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
	Tag = mBase.Tag
	mBase.Tag = Me
		
	ThermColor=xui.PaintOrColorToColor(Props.Get("ThermColor"))
	BackColor=xui.PaintOrColorToColor(Props.Get("BackColor"))
	mValue=Props.Get("Value")
	cvs.Initialize(mBase)
	Draw
End Sub

Private Sub Base_Resize (Width As Double, Height As Double)
  
End Sub

Public Sub GetBase As B4XView
	Return mBase
End Sub

Public Sub setValue(v As Float)
	mValue = Max(mMin, Min(mMax, v))
	Draw
End Sub

Public Sub getValue As Float
	Return mValue
End Sub

Public Sub setMin(v As Float)
	mMin = v
	Draw
End Sub

Public Sub setMax(v As Float)
	mMax = v
	Draw
End Sub

Private Sub Draw
    cvs.ClearRect(cvs.TargetRect)
		
    Dim w As Float = mBase.Width
    Dim h As Float = mBase.Height

    ' --- Dimensioni principali ---
    Dim bulbRadius As Float = w / 5 ' Bulbo
    Dim tubeWidth As Float = w / 6
    Dim tubeLeft As Float = (w - tubeWidth) / 2
    Dim bulbCenterY As Float = h - bulbRadius    ' Bulbo center
    Dim tubeTop As Float = 10dip
	Dim tubeBottom As Float = bulbCenterY - 2dip  ' tubo parte appena sopra il bulbo

	' border
	Dim p As B4XPath
	p.InitializeRoundedRect(CreateRect(cvs.TargetRect.Left,cvs.TargetRect.Top,cvs.TargetRect.Right,cvs.TargetRect.Bottom-bulbRadius),10dip)
	cvs.DrawPath(p,xui.Color_Gray,False,1dip)

	Dim p As B4XPath
	p.InitializeRoundedRect(CreateRect(cvs.TargetRect.Left,cvs.TargetRect.Top,cvs.TargetRect.Right,cvs.TargetRect.Bottom-bulbRadius),10dip)
	cvs.DrawPath(p,xui.Color_Gray,False,1dip)

    ' --- Tubo (vetro) ---
    Dim tubeRect As B4XRect
    tubeRect.Initialize(tubeLeft, tubeTop, tubeLeft + tubeWidth, tubeBottom)
    cvs.DrawRect(tubeRect, BackColor, True, 0)          ' sfondo
    cvs.DrawRect(tubeRect, xui.Color_LightGray, False, 1dip)  ' bordo

    ' --- Riempimento rosso (mercurio) ---
    Dim perc As Float = (mValue - mMin) / (mMax - mMin)
    perc = Max(0, Min(1, perc))
		
    Dim fillHeight As Float = (tubeBottom - tubeTop - bulbRadius) * perc
    Dim fillTop As Float = tubeBottom - fillHeight - bulbRadius
    Dim fillRect As B4XRect
    fillRect.Initialize(tubeLeft, fillTop, tubeLeft + tubeWidth, tubeBottom)
    cvs.DrawRect(fillRect, ThermColor, True, 0)

    ' --- Bulbo inferiore ---
    cvs.DrawCircle(w / 2, bulbCenterY, bulbRadius, ThermColor, True, 0)

    ' --- Capsula superiore ---
    'cvs.DrawRect(CreateRect(tubeLeft, tubeTop - 5dip, tubeLeft + tubeWidth, tubeTop + 5dip), ThermColor, True, 0)

    ' --- Scala con numeri ---
    Dim numSteps As Int = 10 ' numero di tacche principali
    Dim stepHeight As Float = (tubeBottom - tubeTop - bulbRadius) / numSteps
    For i = 0 To numSteps
		Dim y As Float = tubeBottom - i * stepHeight - bulbRadius
        ' Tacca
        cvs.DrawLine(tubeLeft + tubeWidth, y, tubeLeft + tubeWidth + 5dip, y, xui.Color_Black, 1dip)
        ' Numero
        Dim val As Float = mMin + i * (mMax - mMin) / numSteps
        cvs.DrawText(NumberFormat(val, 1, 1), _
                     tubeLeft + tubeWidth + 8dip, y + 3dip, xui.CreateDefaultFont(12), xui.Color_Black, "LEFT")
    Next

    cvs.Invalidate
End Sub

Private Sub CreateRect(l As Float, t As Float, r As Float, b As Float) As B4XRect
    Dim rect As B4XRect
    rect.Initialize(l, t, r, b)
    Return rect
End Sub

Public Sub AnimateTo(Value As Float, Duration As Int)
	Dim steps As Int = Duration / 20
	Dim startValue As Float = mValue
	For i = 1 To steps
		Dim v As Float = startValue + (Value - startValue) * i / steps
		setValue(v)
		Sleep(20)
	Next
End Sub

