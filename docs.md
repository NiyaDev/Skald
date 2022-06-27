### Data structures:
> `MenuOption :: struct { text: string, effect: proc(), };`

### General Procedures:
>__`init_skald() -> ErrorCode`__
>
>initializes core structure and sets default variables.
>
>__Input:__
>
> `speed: u8 = 2` Text speed.
>
> `texture, cursor: raylib.Texture = {}` Default textures. If empty it will create small placeholders.
>
> `font: raylib.Font = {}` Default font. If empty, it will grab Raylib's current font.

>__`free_skald() -> ErrorCode`__
>
>Frees all allocated data.

>__`create_textbox() -> ErrorCode`__
>
>Creates a textbox.
>
>__Input:__
>
>`textboxRect: raylib.Rectangle` Transform of the textbox
>
>`offset: raylib.Vector2` The text offset from the edges of the box.
>
>`texture, cursor: raylib.Texture = {}` Sets textures. If empty, will use default.
>
>`npatch: raylib.N_Patch_Info = {}` The NPatch settings for the texture.
>
>`font: raylib.Font = {}` Sets font. If empty, will use default.
>
>`fontSize: i32 = 20` Font size.
>
>`fontColor: raylib.Color = raylib.BLACK` Font color.
>
>`textDynamic: [dynamic]string = nil` A dynamic list of strings. Each string will be displayed individually per box, and box will keep going until the end.
>
>`textSingle: string = ""` Used if only a single line needed. If both are empty it will fill this with a placegolder.
>
>`options: [dynamic]MenuOption = nil` Used for player choice.
>
>`optionsRect: raylib.Rectangle` Transform of the options box.

>__`update_textboxes() -> ErrorCode`__
>
>Updates the logic of the textboxes.

>__`draw_textboxes() -> ErrorCode`__
>
>Draws the textboxes to screen.

>__`close_textbox() -> ErrorCode`__
>
>Forcibly closes textbox.
>
>__Input:__
>
>`index: int` The index of the textbox to close.

>__`output_error() -> ErrorCode`__
>
>Prints to console the input error code
>
>__Input:__
>
>`error: ErrorCode` Code to print.
