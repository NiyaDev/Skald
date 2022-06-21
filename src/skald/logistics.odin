package skald



//= Imports
import "core:fmt"
import "core:strings"
import "core:io"
import "../raylib"

//= Constants

//= Global Variables

//= Structures

//= Enumerations

//= Procedures

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

				reader:  strings.Reader;
				strings.reader_init(&reader, textbox.completeText[textbox.dispLine]);

				builder: strings.Builder;
				strings.init_builder(&builder);


				for o:=0; o < int(textbox.dispChar); o+=1 {
					output, error := strings.reader_read_byte(&reader);

					if error != io.Error.None {
						textbox.clickable = true;
						break;
					}

					strings.write_byte(&builder, output);
				}

				textbox.currentText = strings.to_string(builder);
			} else {
				

				textbox.displayCursor = !textbox.displayCursor;
			}
		}

		textboxCoreData.updateTic = 0;
	} else do textboxCoreData.updateTic += 1;

	if len(textboxCoreData.textboxes) != 0 {
		textbox: ^Textbox = &textboxCoreData.textboxes[len(textboxCoreData.textboxes) - 1];

		if raylib.is_key_pressed(raylib.Keyboard_Key.KEY_W) do textbox.positionCursor-=1;
		if raylib.is_key_pressed(raylib.Keyboard_Key.KEY_S) do textbox.positionCursor+=1;

		if textbox.positionCursor < 0 do textbox.positionCursor = 0;
		if textbox.positionCursor > i32(len(textbox.options) - 1) do textbox.positionCursor = i32(len(textbox.options) - 1);
	}

	if raylib.is_key_pressed(raylib.Keyboard_Key.KEY_SPACE) && numOfTextboxes > 0 {
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
				res := close_textbox(0);
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
		textbox: Textbox = textboxCoreData.textboxes[i];

		text: cstring = strings.clone_to_cstring(textbox.currentText);
		textPosition: raylib.Vector2 = raylib.Vector2{
			textbox.textboxRect.x + textbox.offset.x,
			textbox.textboxRect.y + textbox.offset.y};

		raylib.draw_texture_n_patch(
			textbox.texture, textbox.nPatch,
			textbox.textboxRect,
			raylib.Vector2{0,0}, 0,
			raylib.WHITE);
		raylib.draw_text_ex(
			textbox.font, text,
			textPosition,
			textbox.fontSize, 1,
			textbox.fontColor);

		delete(text);

		// No options
		if len(textbox.options) == 1 && textbox.displayCursor {
			cursorX: i32 = i32((textbox.textboxRect.x + textbox.textboxRect.width)  - textbox.offset.x);
			cursorY: i32 = i32((textbox.textboxRect.y + textbox.textboxRect.height) - textbox.offset.y);

			raylib.draw_texture(textbox.cursor, cursorX, cursorY, raylib.WHITE);
		}
		// Options
	//	if len(textbox.options) > 1 {
		if textbox.options[0].text != "" {
			if textbox.clickable && int(textbox.dispLine) == len(textbox.completeText) - 1 {
				raylib.draw_texture_n_patch(
					textbox.texture, textbox.nPatch,
					textbox.optionsRect,
					raylib.Vector2{0,0}, 0,
					raylib.WHITE);
				
				for o:=0; o < len(textbox.options); o+=1 {
					textPosition: raylib.Vector2 = raylib.Vector2{
						textbox.optionsRect.x + 40,
						textbox.optionsRect.y + textbox.fontSize + f32(o) * textbox.fontSize};
					text: cstring = strings.clone_to_cstring(textbox.options[o].text);

					raylib.draw_text_ex(
						textbox.font, text,
						textPosition,
						textbox.fontSize, 1,
						raylib.BLACK);
					delete(text);
				}

				if textbox.displayCursor {
					cursorX: i32 = i32((textbox.optionsRect.x + 16));
					cursorY: i32 = i32(textbox.optionsRect.y + textbox.fontSize + (f32(textbox.positionCursor) * textbox.fontSize));
					
					raylib.draw_texture(textbox.cursor, cursorX, cursorY, raylib.WHITE);
				}
			}
		}
	}

	return .none;
}

// Default procedure
default_option :: proc() {
	fmt.printf("DEFAULT PROCEDURE\n");
}