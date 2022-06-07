package textbox_old
///=-------------------=///
//  Written: 2022/05/28  //
//  Edited:  2022/06/06  //
///=-------------------=///



import fmt "core:fmt"
import str "core:strings"
import io  "core:io"

import ray "../raylib"


//= Global
@(private)
textboxData: TextboxData;


//= Enumerations
TextboxFlags     :: enum {}
TextboxFlags_Set :: bit_set[TextboxFlags]

TextboxType      :: enum { normal, menu, }


//= Structs
@(private)
TextboxData :: struct {
	texture:   ray.Texture,
	nPatch:    ray.N_Patch_Info,
	font:      ray.Font,
	cursor:    ray.Texture,

	textSpeed: u32,
	updateTic: u32,

	textboxes: [dynamic]Textbox,
}

@(private)
Textbox :: struct {
	position: ray.Vector2,
	size:     ray.Vector2,
	type:     TextboxType,
	text:     [dynamic]string,

	// TextboxType.normal
	curText:  string,
	// TextboxType.menu
	options:  [dynamic]MenuOptions,
	cursor:   i32,

	// For timing and interaction
	canBeClicked: bool,
	displayChar:  u32,
	displayLine:  u32,
}

MenuOptions :: struct {
	position: ray.Vector2,
	text:     string,
	effect:   proc(),
}



//= Constants


//= Procedures
// TODO: create error checking procedure for initialization to check in detail
// TODO: Clean up

//- Initialization
// TODO: load text speed
// Initialize textbox data with a very basic gray bg and current font
@(private)
init_textbox_none :: proc(value: u8) -> u32 {
	// Texture
	image: ray.Image    = ray.gen_image_color(3, 3, ray.GRAY);
	textboxData.texture = ray.load_texture_from_image(image);
	ray.unload_image(image);

	// NPatch
	textboxData.nPatch = {};
	textboxData.nPatch.source = ray.Rectangle{0,0,3,3};
	textboxData.nPatch.left   = 1;
	textboxData.nPatch.top    = 1;
	textboxData.nPatch.right  = 1;
	textboxData.nPatch.bottom = 1;
	textboxData.nPatch.layout = i32(ray.N_Patch_Layout.NPATCH_NINE_PATCH);

	// Font
	textboxData.font = ray.get_font_default();

	// Textboxes
	textboxData.textboxes = make([dynamic]Textbox);

	// Checking
	if textboxData.texture == {} do return 1;
	if textboxData.nPatch  == {} do return 2;
	if textboxData.font    == {} do return 3;

	return 0;
}
// Initialize textbox data with inputs
@(private)
init_textbox_input :: proc(texture: ray.Texture = {}, cursor: ray.Texture = {}, npatch: ray.N_Patch_Info = {}, font: ray.Font = {}) -> u32 {
	// Texture
	if texture == {} {
		image: ray.Image    = ray.gen_image_color(3, 3, ray.GRAY);
		textboxData.texture = ray.load_texture_from_image(image);
		ray.unload_image(image);
	} else do textboxData.texture = texture;

	// NPatch
	if npatch == {} {
		textboxData.nPatch = {};
		textboxData.nPatch.source = ray.Rectangle{0,0,3,3};
		textboxData.nPatch.left   = 1;
		textboxData.nPatch.top    = 1;
		textboxData.nPatch.right  = 1;
		textboxData.nPatch.bottom = 1;
		textboxData.nPatch.layout = i32(ray.N_Patch_Layout.NPATCH_NINE_PATCH);
	} else do textboxData.nPatch = npatch;

	// Font
	if font == {} do textboxData.font = ray.get_font_default();
	else          do textboxData.font = font;

	// Cursor
	if cursor == {} {
		image: ray.Image   = ray.gen_image_color(20, 20, ray.BLACK);
		textboxData.cursor = ray.load_texture_from_image(image);
		ray.unload_image(image);
	} else do textboxData.cursor = cursor;

	// Options
	textboxData.textSpeed = 5;
	textboxData.updateTic = 0;

	// Textboxes
	textboxData.textboxes = make([dynamic]Textbox);

	// Checking
	if textboxData.texture == {} do return 1;
	if textboxData.nPatch  == {} do return 2;
	if textboxData.font    == {} do return 3;

	return 0;
}
// Initialization overloading
init_textbox :: proc {init_textbox_none, init_textbox_input}


//- Creating boxes
// Creates a textbox
create_textbox :: proc(position: ray.Vector2 = {0,0}, size: ray.Vector2 = {10,10}, text: [dynamic]string = nil) -> u32 {
	newBox: Textbox     = {};
	newBox.position     = position;
	newBox.size         = size;
	newBox.type         = TextboxType.normal;
	newBox.canBeClicked = false;
	newBox.displayChar  = 0;
	newBox.displayLine  = 0;
	newBox.curText      = "";

	// Unused values
	newBox.options = nil;
	newBox.cursor  = 0;

	// Text
	if text == nil do newBox.text = make([dynamic]string);
	else           do newBox.text = text;

	// Checking
	// TODO:

	append(&textboxData.textboxes, newBox);
	return 0;
}
// Creates a menu
create_menu :: proc(position: ray.Vector2 = {0,0}, size: ray.Vector2 = {10,10}, text: [dynamic]string = nil, options: [dynamic]MenuOptions = nil) -> u32 {
	newBox: Textbox     = {};
	newBox.position     = position;
	newBox.size         = size;
	newBox.type         = TextboxType.menu;
	newBox.canBeClicked = false;
	newBox.displayChar  = 0;
	newBox.displayLine  = 0;
	newBox.text = text;

	// Menu options
	if options == nil do newBox.options = make([dynamic]MenuOptions);
	else              do newBox.options = options;
	newBox.cursor  = 0;

	// Checking
	// TODO:
	
	append(&textboxData.textboxes, newBox);
	return 0;
}


//- 
//
// TODO: This needs a strong re-write
update_textboxes :: proc() {
	if len(textboxData.textboxes) == 0 do return;
	// Updating text
	if textboxData.updateTic >= textboxData.textSpeed {
		for i:=0; i < len(textboxData.textboxes); i+=1 {
			txb: ^Textbox = &textboxData.textboxes[i];

			textboxData.textboxes[i].displayChar += 1;

			if int(textboxData.textboxes[i].displayLine) < len(textboxData.textboxes[i].text) {
				line: u32 = textboxData.textboxes[i].displayLine;

				reader: str.Reader;
				str.reader_init(&reader, textboxData.textboxes[i].text[line]);

				builder: str.Builder;
				str.init_builder_none(&builder);
				for f:u32=0; f < textboxData.textboxes[i].displayChar; f+=1 {
					out, error := str.reader_read_byte(&reader);
					
					if error != io.Error.None {
						textboxData.textboxes[i].canBeClicked = true;
						break;
					}

					str.write_byte(&builder, out);
				}

				textboxData.textboxes[i].curText = str.to_string(builder);
			}
			
		}
		textboxData.updateTic = 0;
	} else do textboxData.updateTic += 1;

	// Updating state
	if textboxData.textboxes[0].type == TextboxType.normal {
		if ray.is_key_pressed(ray.Keyboard_Key.KEY_SPACE) && len(textboxData.textboxes) > 0 {
			if int(textboxData.textboxes[0].displayLine) + 1 < len(textboxData.textboxes[0].text) {
				if textboxData.textboxes[0].canBeClicked {
					textboxData.textboxes[0].displayLine += 1;
					textboxData.textboxes[0].displayChar  = 0;
					textboxData.textboxes[0].canBeClicked = false;
				} else {
					textboxData.textboxes[0].displayChar = u32(len(textboxData.textboxes[0].text[textboxData.textboxes[0].displayLine]));
				}
			} else do shave_textbox();
		}
	} else {
		cur:    int = int(textboxData.textboxes[0].cursor);
		length: int = len(textboxData.textboxes[0].options) - 1;

		if ray.is_key_pressed(ray.Keyboard_Key.KEY_SPACE) && len(textboxData.textboxes) > 0 {
			if int(textboxData.textboxes[0].displayLine) + 1 < len(textboxData.textboxes[0].text) {
				if textboxData.textboxes[0].canBeClicked {
					textboxData.textboxes[0].displayLine += 1;
					textboxData.textboxes[0].displayChar  = 0;
					textboxData.textboxes[0].canBeClicked = false;
				} else {
					textboxData.textboxes[0].displayChar = u32(len(textboxData.textboxes[0].text[textboxData.textboxes[0].displayLine]));
				}
			} else {
				textboxData.textboxes[0].options[cur].effect();
				shave_textbox();
			}
			
		}

		if ray.is_key_pressed(ray.Keyboard_Key.KEY_W) {
			if cur == 0 do textboxData.textboxes[0].cursor  = i32(length);
			else        do textboxData.textboxes[0].cursor -= 1;
		}
		if ray.is_key_pressed(ray.Keyboard_Key.KEY_S) {
			if cur == length do textboxData.textboxes[0].cursor  = 0;
			else             do textboxData.textboxes[0].cursor += 1;
		}
	}
}
//
draw_textboxes :: proc() {
	for i:=0; i < len(textboxData.textboxes); i+=1 {
		position: ray.Vector2 = textboxData.textboxes[i].position;
		size: ray.Vector2     = textboxData.textboxes[i].size;

		line: u32             = textboxData.textboxes[i].displayLine;
		stri: cstring          = str.clone_to_cstring(textboxData.textboxes[i].curText);

		ray.draw_texture_n_patch(
			textboxData.texture,
			textboxData.nPatch,
			ray.Rectangle{position.x, position.y, size.x, size.y},
			ray.Vector2{0,0},
			0, ray.WHITE);
		ray.draw_text(
			stri,
			i32(position.x + 32), i32(position.y + 32),
			20, ray.BLACK);
		delete(stri);

		if textboxData.textboxes[i].type == TextboxType.menu {
			optCount: int = len(textboxData.textboxes[i].options);
			height:   int = 64 + (optCount * 20);
			width:    int = 250;
			rect: ray.Rectangle = {
				position.x + size.x - f32(width),
				position.y + (size.y - f32(height)),
				f32(width), f32(height)};

			ray.draw_texture_n_patch(
				textboxData.texture,
				textboxData.nPatch,
				rect,
				ray.Vector2{0,0},
				0, ray.WHITE);

			for o:=0; o < optCount; o+=1 {
				option: cstring = str.clone_to_cstring(textboxData.textboxes[i].options[o].text);
				targetX: i32 = i32(rect.x) + 64;
				targetY: i32 = i32(rect.y) + 32 + (i32(o) * 20);
				
				ray.draw_text(
					option,
					targetX, targetY,
					20, ray.BLACK);
			}
			ray.draw_texture(
				textboxData.cursor,
				i32(rect.x) + 32,
				i32(rect.y) + 32 + (i32(textboxData.textboxes[i].cursor) * 20),
				ray.WHITE);
		}
	}
}


//-
//
shave_textbox :: proc() {
	fmt.printf("Shaving textbox\n");
	newList: [dynamic]Textbox = make([dynamic]Textbox);

	for i:=1; i < len(textboxData.textboxes); i+=1 {
		append(&newList, textboxData.textboxes[i]);
	}

	delete(textboxData.textboxes);
	textboxData.textboxes = newList;
}