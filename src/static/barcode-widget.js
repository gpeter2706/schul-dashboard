class BarcodeWidget {
    constructor(options) {
        this.beep0 = new Audio('/beep0.mp3');
        this.beep1 = new Audio('/beep1.mp3');
        this.beep2 = new Audio('/beep2.mp3');
    
        this.element = options.element;
        let container = $("<div style='border: 1px solid #ddd; padding: 15px; border-radius: 15px; box-shadow: 0px 0px 5px rgba(0,0,0,0.2); margin-bottom: 15px; background-color: #eee;'>");
        let video_container = $("<div style='position: relative; width: 100%; overflow: hidden; height: 200px; margin-bottom: 15px; border-radius: 15px; border: 1px solid #aaa;'>");
        let video = $("<video class='rounded shadow mb-3' style='object-fit: cover; position: absolute; left: 0; top: 0; width: 100%; height: 100%;'>");
        let hint = $("<div class='text-muted text-sm'>").text('Alternativ kannst du den Barcode auch hier eingeben:');
        let input_group = $("<div class='input-group mt-1'>");
        let text_input = $("<input type='text' class='form-control' style='text-align: center'>");
        let submit_button = $("<button class='btn btn-success' type='button'>").text('Senden');
        input_group.append(text_input);
        input_group.append($("<div class='input-group-append'>").append(submit_button));
        video_container.append(video);
        container.append(video_container);
        container.append(hint);
        container.append(input_group);
        this.element.append(container);
        this.text_input = text_input;

        this.last_scanned = null;

        let hints = null;
        if (options.formats) {
            let hints = new Map();
            let formats = options.formats;
            hints.set(ZXing.DecodeHintType.POSSIBLE_FORMATS, formats);
        }
        this.on_scan = options.on_scan;
        let codeReader = new ZXing.BrowserMultiFormatReader(hints);
        codeReader.decodeFromVideoDevice(null, video[0], (result, err) => {
            if (result) this._on_scan(result.text, true);
        }).catch(e => {
            video_container.hide();
            hint.text('Es konnte keine Kamera erkannt werden. Versuch es bitte mit einem anderen Gerät oder gib den Barcode manuell ein:');
        });

        let self = this;
        submit_button.click(function() {
            let s = text_input.val().trim();
            if (s.length > 0) self._on_scan(s, false);
        });

        text_input.keydown(function(e) {
            if (e.key === 'Enter') {
                submit_button.click();
            }
        })
    }

    _on_scan(s, scanned) {
        if (scanned) {
            if (s !== this.last_scanned) {
                this.beep0.play();
                this.last_scanned = s;
                this.on_scan(s, true);
            }
        } else {
            this.on_scan(s, false);
            this.text_input.val('').focus();
        }
    }
}