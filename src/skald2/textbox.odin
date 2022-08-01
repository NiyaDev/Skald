package skald2



//= Imports
import "../raylib"


//= Constants

//= Global Variables

//= Structures
Textbox :: struct {
	using textures:  Textures,
	using transform: Transform,

	fontSize:  f32,
	fontColor: raylib.Color,

	completeText: [dynamic]string,
	currentText:  string,

	options: OptionBox,

	updateTick: u8,
	cursorTick: u8,
	fontSpeed:  u8,

	finishedPrinting: bool,
	displayCursor:    bool,

	cursorPosition: i32,
	displayChar, displayLine: u32,
}

OptionBox :: struct {
	using textures:  Textures,
	using transform: Transform,

	options: [dynamic]MenuOption,
}

Textures :: struct {
	cursor:  raylib.Texture,
	texture: raylib.Texture,
	nPatch:  raylib.N_Patch_Info,
	font:    raylib.Font,
}

Transform :: struct {
	position: raylib.Rectangle,
	offset:   raylib.Rectangle,
}

MenuOption :: struct {
	text:   string,
	effect: proc(),
}


//= Enumerations

//= Procedures
create_textbox :: proc{ create_textbox_gfx };
create_textbox_gfx :: proc(
		textures:    Textures={},
		transform:   Transform={},
		fontSize:    f32=0,
		fontSpeed:   u8=255,
		fontColor:   raylib.Color=raylib.BLACK,
		textDynamic: [dynamic]string=nil,
		textSingle:  string="",
		options:     OptionBox={}) {
	textbox: Textbox = {};

	// Textures
	if textures == {} do textbox.textures = textboxCore.defaultTextures;
	else              do textbox.textures = textures;

	// Transform
	if transform == {} {
		textbox.position = { 0, 0,196,96};
		textbox.offset   = {32,32,132,32};
	} else do textbox.transform = transform;

	// Textspeed / Textsize / Textcolor
	if fontSize  == 0 do textbox.fontSize  = textboxCore.defaultTextSize;
	else              do textbox.fontSize  = fontSize;
	if fontSpeed == 0 do textbox.fontSpeed = textboxCore.defaultTextSpeed;
	else              do textbox.fontSpeed = fontSpeed;
	textbox.fontColor = fontColor;

	// Text
	if textDynamic == nil && textSingle == "" do append(&textbox.completeText, "PLACEHOLDER");
	if textSingle  != ""  do append(&textbox.completeText, textSingle);
	if textDynamic != nil do textbox.completeText = textDynamic;

	// Options
	if options.options == nil {
		textbox.options.textures  = textbox.textures;
		textbox.options.transform = textbox.transform;
		append(&textbox.options.options, MenuOption{"",default_proc});
	}

	append(&textboxCore.textboxes, textbox);
}

default_proc :: proc() {}


update_textboxes :: proc() {}
draw_textboxes :: proc() {
	length := len(textboxCore.textboxes);

	// Iterate for every textbox
	for i:=0; i<length; i+=1 {
		textbox: Textbox = textboxCore.textboxes[i];

		// Copy current string
		text: cstring = strings.clone_to_cstring(textbox.currentText);
	}
}