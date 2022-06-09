package skald
//=-------------------=//
// Written: 2022/06/07 //
// Edited:  2022/06/07 //
// Version:   0.01.0   //
//=-------------------=//



//= Imports
import fmt "core:fmt"
import str "core:strings"
import ray "../raylib"



//= Global Variables
@(private)
textboxCoreData: ^TextboxCoreData;



//= Constants
@(private)
Vector2   :: ray.Vector2
Texture   :: ray.Texture
NPatch    :: ray.N_Patch_Info
NINE      :: i32(ray.N_Patch_Layout.NPATCH_NINE_PATCH)
Font      :: ray.Font
Rectangle :: ray.Rectangle



//= Enumerations
TextboxType :: enum { default, menu, }



//= Structures

// Core global structure
@(private)
TextboxCoreData :: struct {
	textspeed: u8,
	updateTic: u8,

	defaultTexture:  Texture,
	defaultCursor:   Texture,
	defaultFont:     Font,

	textboxes: [dynamic]Textbox,
}

// Textbox structure
// TODO: color
@(private)
Textbox :: struct {
	position: Vector2,
	size:     Vector2,
	offset:   Vector2,

	type:     TextboxType, // ???

	texture:  Texture,
	cursor:   Texture,
	nPatch:   NPatch,
	font:     Font,

	fontSize: i32,

	currentText:  string,
	completeText: [dynamic]string,

	options: [dynamic]MenuOption,

	clickable:          bool,
	displayCursor:      bool,
	dispChar, dispLine: u32,
}

MenuOption :: struct {
	text:   string,
	effect: proc(),
}



//= Procedures
// TODO: change the return values to a custom error code
// TODO: changing core data

//- Initialization / Freeing
// TODO: check for errors at end and pprovide error codes
// TODO: Debugging text
init_skald :: proc(
		speed: u8        = 5,
		texture: Texture = {},
		cursor: Texture  = {},
		font: Font       = {},) -> u32 {
	textboxCoreData = new(TextboxCoreData);
	textboxCoreData.textspeed = speed;
	textboxCoreData.updateTic = 0;

	// Checking for empty texture input
	if texture == {} {
		img: ray.Image = ray.gen_image_gradient_v(48, 48, ray.BLACK, ray.WHITE);
		textboxCoreData.defaultTexture = ray.load_texture_from_image(img);
		ray.unload_image(img);
	} else do textboxCoreData.defaultTexture = texture;

	// Checking for empty Cursor input
	if cursor == {} {
		img: ray.Image = ray.gen_image_color(20, 20, ray.BLACK);
		textboxCoreData.defaultCursor = ray.load_texture_from_image(img);
		ray.unload_image(img);
	} else do textboxCoreData.defaultCursor = cursor;

	// Checking for empty Font input
	if font == {} do textboxCoreData.defaultFont = ray.get_font_default();
	else          do textboxCoreData.defaultFont = font;

	textboxCoreData.textboxes = make([dynamic]Textbox);

	return 0;
}
free_skald :: proc() -> u32 {
	ray.unload_texture(textboxCoreData.defaultTexture);
	ray.unload_texture(textboxCoreData.defaultCursor);
	ray.unload_font(textboxCoreData.defaultFont);

	delete(textboxCoreData.textboxes);
	free(textboxCoreData);

	return 0;
}
@(private)
init_check :: proc() -> bool {
	if textboxCoreData.defaultTexture == {} do return false;
	if textboxCoreData.defaultCursor  == {} do return false;
	if textboxCoreData.defaultFont    == {} do return false;

	return true;
}

//- Textbox creation
create_textbox :: proc(
		position: Vector2 = {  0,  0},
		size:     Vector2 = {200,100},
		offset:   Vector2 = { 16, 16},
		
		texture:  Texture = {},
		cursor:   Texture = {},
		npatch:   NPatch  = {},
		font:     Font    = {},
		fontSize: i32     = 20,
		
		textDynamic:  [dynamic]string     = nil,
		textSingle:   string              = "",
		options:      [dynamic]MenuOption = nil) -> u32 {
	init_check();

	fmt.printf("Creating a textbox\n");

	textbox: Textbox = {};
	textbox.position = position;
	textbox.size     = size;
	textbox.offset   = offset;
	textbox.fontSize = fontSize;
	
	// Checking for empty texture input
	if texture == {} do textbox.texture = textboxCoreData.defaultTexture;
	else             do textbox.texture = texture;

	// Checking for empty cursor input
	if cursor == {}  do textbox.cursor = textboxCoreData.defaultCursor;
	else             do textbox.cursor = cursor;

	// Checking for empty font input
	if font == {}    do textbox.font = textboxCoreData.defaultFont;
	else             do textbox.font = font;

	// Calculating NPatch
	if npatch == {} {
		textbox.nPatch = {};
		textbox.nPatch.source = Rectangle{0, 0, f32(textbox.texture.width), f32(textbox.texture.height)};
		textbox.nPatch.left   = textbox.texture.width  / 3;
		textbox.nPatch.top    = textbox.texture.height / 3;
		textbox.nPatch.right  = textbox.texture.width  / 3;
		textbox.nPatch.bottom = textbox.texture.height / 3;
		textbox.nPatch.layout = NINE;
	} else do textbox.nPatch = npatch;

	// Text
	if textDynamic == nil {
		textbox.completeText = make([dynamic]string);
		if textSingle != "" do append(&textbox.completeText,textSingle);
		else             do append(&textbox.completeText,"ERROR: NO TEXT INPUT");
	} else do textbox.completeText = textDynamic;

	// Options
	if options == nil {
		textbox.options = make([dynamic]MenuOption);
		
		defaultOption: MenuOption = {"", default_option};
		append(&textbox.options,defaultOption);
	} else do textbox.options = options;

	append(&textboxCoreData.textboxes, textbox);

	return 0;
}

//- Updating / Drawing
// Update
update_textboxes :: proc() {
	numOfTextboxes := len(textboxCoreData.textboxes);
	
	if textboxCoreData.updateTic == (textboxCoreData.textspeed * 100) {
		for i:=0; i < numOfTextboxes; i +=1 {
			textbox: Textbox    = textboxCoreData.textboxes[i];
			

			textbox.displayCursor = !textbox.displayCursor;
		}

		textboxCoreData.updateTic = 0;
	} else do textboxCoreData.updateTic += 1;
}
// Draw
draw_textboxes :: proc() {
	numOfTextboxes := len(textboxCoreData.textboxes);
	
	for i:=0; i < numOfTextboxes; i +=1 {
		textbox: Textbox    = textboxCoreData.textboxes[i];
		bodyRect: Rectangle = {textbox.position.x, textbox.position.y, textbox.size.x, textbox.size.y};

		text: cstring = str.clone_to_cstring(textbox.currentText);
		textX: i32    = i32(bodyRect.x + textbox.offset.x);
		textY: i32    = i32(bodyRect.y + textbox.offset.y);

		ray.draw_texture_n_patch(textbox.texture, textbox.nPatch, bodyRect, Vector2{0,0}, 0, ray.WHITE);
		ray.draw_text(text, textX, textY, textbox.fontSize, ray.BLACK);

		//DrawTexture(Texture2D texture, int posX, int posY, Color tint);
		if len(textbox.options) == 1 && textbox.displayCursor {
			cursorX: i32 = i32((textbox.position.x + textbox.size.x) - textbox.offset.x);
			cursorY: i32 = i32((textbox.position.y + textbox.size.y) - textbox.offset.y);

			ray.draw_texture(textbox.cursor, cursorX, cursorY, ray.WHITE);
		}
	}
}

//- Default Option
default_option :: proc() {

}