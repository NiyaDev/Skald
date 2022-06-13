package skald
//=-------------------=//
// Written: 2022/06/07 //
// Edited:  2022/06/13 //
// Version:   0.01.0   //
//=-------------------=//



//= Imports
import fmt "core:fmt"
import str "core:strings"
import io  "core:io"
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
	positionCursor:     i32,
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
init_skald :: proc(
		speed: u8        = 2,
		texture: Texture = {},
		cursor: Texture  = {},
		font: Font       = {}) -> ErrorCode {
	
	if textboxCoreData != nil do return .already_init_skald;

	textboxCoreData = new(TextboxCoreData);
	textboxCoreData.textspeed = speed;
	textboxCoreData.updateTic = 0;

	// Checking for empty texture input
	if texture == {} {
		img: ray.Image = ray.gen_image_gradient_v(48, 48, ray.BLACK, ray.WHITE);
		textboxCoreData.defaultTexture = ray.load_texture_from_image(img);
		ray.unload_image(img);
		
		if textboxCoreData.defaultTexture == {} do return .def_texture_missing;
	} else do textboxCoreData.defaultTexture = texture;

	// Checking for empty Cursor input
	if cursor == {} {
		img: ray.Image = ray.gen_image_color(16, 16, ray.BLACK);
		textboxCoreData.defaultCursor = ray.load_texture_from_image(img);
		ray.unload_image(img);
		
		if textboxCoreData.defaultCursor == {} do return .def_cursor_missing;
	} else do textboxCoreData.defaultCursor = cursor;

	// Checking for empty Font input
	if font == {} {
		textboxCoreData.defaultFont = ray.get_font_default();
		
		if textboxCoreData.defaultFont == {} do return .def_font_missing;
	} else do textboxCoreData.defaultFont = font;

	textboxCoreData.textboxes = make([dynamic]Textbox);

	return .none;
}
free_skald :: proc() -> ErrorCode {
	ray.unload_texture(textboxCoreData.defaultTexture);
	ray.unload_texture(textboxCoreData.defaultCursor);
	ray.unload_font(textboxCoreData.defaultFont);

	delete(textboxCoreData.textboxes);
	free(textboxCoreData);

	return .none;
}
@(private)
init_check :: proc() -> ErrorCode {
	if textboxCoreData == nil do return .init_failed_check;

	if textboxCoreData.defaultTexture == {} do return .def_texture_missing;
	if textboxCoreData.defaultCursor  == {} do return .def_cursor_missing;
	if textboxCoreData.defaultFont    == {} do return .def_font_missing;

	return .none;
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
		options:      [dynamic]MenuOption = nil) -> ErrorCode {
	res := init_check();
	if output_error(res) do return res;

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

	return .none;
}

//- Updating / Drawing
// Update
// TODO: detach cursor blinking from update tic
update_textboxes :: proc() -> ErrorCode {
	numOfTextboxes := len(textboxCoreData.textboxes);
	
	if textboxCoreData.updateTic >= (textboxCoreData.textspeed * 5) {
		for i:=0; i < numOfTextboxes; i +=1 {
			textbox: ^Textbox    = &textboxCoreData.textboxes[i];
			
			if textbox.currentText != textbox.completeText[textbox.dispLine] {
				textbox.dispChar += 1;

				delete(textbox.currentText);

				reader:  str.Reader;
				str.reader_init(&reader, textbox.completeText[textbox.dispLine]);

				builder: str.Builder;
				str.init_builder(&builder);


				for o:=0; o < int(textbox.dispChar); o+=1 {
					output, error := str.reader_read_byte(&reader);

					if error != io.Error.None {
						textbox.clickable = true;
						break;
					}

					str.write_byte(&builder, output);
				}

				textbox.currentText = str.to_string(builder);
			} else {
				

				textbox.displayCursor = !textbox.displayCursor;
			}
		}

		textboxCoreData.updateTic = 0;
	} else do textboxCoreData.updateTic += 1;

	if len(textboxCoreData.textboxes) != 0 {
		textbox: ^Textbox = &textboxCoreData.textboxes[len(textboxCoreData.textboxes) - 1];

		if ray.is_key_pressed(ray.Keyboard_Key.KEY_W) do textbox.positionCursor-=1;
		if ray.is_key_pressed(ray.Keyboard_Key.KEY_S) do textbox.positionCursor+=1;

		if textbox.positionCursor < 0 do textbox.positionCursor = 0;
		if textbox.positionCursor > i32(len(textbox.options) - 1) do textbox.positionCursor = i32(len(textbox.options) - 1);
	}

	if ray.is_key_pressed(ray.Keyboard_Key.KEY_SPACE) && numOfTextboxes > 0 {
		textbox: ^Textbox = &textboxCoreData.textboxes[len(textboxCoreData.textboxes) - 1];

		strLength: u32 = u32(len(textbox.completeText[textbox.dispLine]) - 1);
		arrLength: u32 = u32(len(textbox.completeText) - 1);

		if textbox.dispChar <= strLength {
			textbox.dispChar = strLength+1;
			textbox.clickable = true;
			return .none;
		} else {
			if textbox.dispLine < arrLength {
				textbox.dispLine += 1;
				textbox.dispChar  = 0;
				textbox.clickable = false;
				return .none;
			} else {
				textbox.options[textbox.positionCursor].effect();
				res := close_textbox(len(textboxCoreData.textboxes) - 1);
				if output_error(res) do return res;
				return .none;
			}
		}
	}

	return .none;
}
// Draw
draw_textboxes :: proc() -> ErrorCode {
	numOfTextboxes := len(textboxCoreData.textboxes);
	
	for i:=0; i < numOfTextboxes; i +=1 {
		textbox: Textbox    = textboxCoreData.textboxes[i];
		bodyRect: Rectangle = {textbox.position.x, textbox.position.y, textbox.size.x, textbox.size.y};

		text: cstring = str.clone_to_cstring(textbox.currentText);
		textX: i32    = i32(bodyRect.x + textbox.offset.x);
		textY: i32    = i32(bodyRect.y + textbox.offset.y);

		ray.draw_texture_n_patch(textbox.texture, textbox.nPatch, bodyRect, Vector2{0,0}, 0, ray.WHITE);
		ray.draw_text(text, textX, textY, textbox.fontSize, ray.BLACK);

		delete(text);

		// No options
		if len(textbox.options) == 1 && textbox.displayCursor {
			cursorX: i32 = i32((textbox.position.x + textbox.size.x) - textbox.offset.x);
			cursorY: i32 = i32((textbox.position.y + textbox.size.y) - textbox.offset.y);

			ray.draw_texture(textbox.cursor, cursorX, cursorY, ray.WHITE);
		}
		// Options
		if len(textbox.options) > 1 {
			if textbox.clickable {
				rect: Rectangle = {
					bodyRect.width * 2/3, bodyRect.y,
					bodyRect.width * 1/3, f32(32 + (len(textbox.options) * 20))};
				ray.draw_texture_n_patch(textbox.texture, textbox.nPatch, rect, Vector2{0,0}, 0, ray.WHITE);
				
				for o:=0; o < len(textbox.options); o+=1 {
					text: cstring = str.clone_to_cstring(textbox.options[o].text);
					ray.draw_text(text, i32(rect.x + 40), i32(rect.y + 16) + i32(o) * textbox.fontSize, textbox.fontSize, ray.BLACK);
					delete(text);
				}

				if textbox.displayCursor {
					cursorX: i32 = i32((rect.x + 16));
					cursorY: i32 = i32(rect.y + 16) + i32(textbox.positionCursor) * textbox.fontSize;
					
					ray.draw_texture(textbox.cursor, cursorX, cursorY, ray.WHITE);
				}
			}
		}
	}

	return .none;
}
// Close textbox
close_textbox :: proc(index: int) -> ErrorCode {
	if len(textboxCoreData.textboxes) == 0    do return .closing_oob;
	if index > len(textboxCoreData.textboxes) do return .closing_oob;

	listCopy: [dynamic]Textbox = make([dynamic]Textbox);

	for i:=0; i < len(textboxCoreData.textboxes); i+=1 {
		if i == index do continue;
		append(&listCopy, textboxCoreData.textboxes[i]);
	}

	delete(textboxCoreData.textboxes);
	textboxCoreData.textboxes = listCopy;

	return .none;
}


//- Default Option
default_option :: proc() {
	fmt.printf("DEFAULT PROCEDURE\n");
}