import { Component, Input } from '@angular/core';
import {ObjectUtils} from "../../../lib/common/utils/object-utils";

@Component({
    selector: 'card-layout',
    templateUrl: './card-layout.html'
})
export class CardLayoutComponent {

    @Input() headerCss: any;
    @Input() bodyCss: any; 
    @Input() cardCss: any;
    @Input() cardToolbar: any;

    ngOnInit() {

        if(ObjectUtils.isUndefined(this.cardToolbar)){
            this.cardToolbar = true;
        }
    }
    
}