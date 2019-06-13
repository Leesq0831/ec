var CUES = {
    tip:function(options){
        var msg = options.msg;
        var type = options.type?options.type:'info';
        var time = options.time?options.time:1000;
        var elma = this.createdom({"tag":"div","classname":"tippop","msg":'<div class="text '+type+'">'+msg+'</div></div>'});
        document.body.appendChild(elma);
        setTimeout(function(){
            elma.style.opacity = 0;
            elma.style.webkitTransition = 'all 1.5s';
            setTimeout(function(){
                options.callback && options.callback();
                elma.remove();
            },1000);
        },time);
    },
    alert:function(options){
        var msg = options.msg;
        var elma = this.createdom({"tag":"div","classname":"tippop_alert"});
        var elmb = this.createdom({"tag":"p","classname":"tippop_alert_t","msg":options.msg});
        var elmc = this.createdom({"tag":"a","classname":"tippop_alert_b","msg":"确定"});
        elma.appendChild(elmb),elma.appendChild(elmc);
        document.body.appendChild(elma);

        var elm_bg = this.createdom({"tag":"div","classname":"tippop_bg"});
        document.body.appendChild(elm_bg);

        elmc.addEventListener('click',function(){
            elm_bg.remove();
            elma.remove();
            options.callback && options.callback();
        },false);
    },
    confirm:function(options){
        var msg = options.msg;
        var elma = this.createdom({"tag":"div","classname":"tippop_alert"});
        var elmb = this.createdom({"tag":"p","classname":"tippop_alert_t","msg":options.msg});
        var elmc = this.createdom({"tag":"p","classname":"tippop_alert_b"});
        var a_cal = this.createdom({"tag":"a","classname":"tippop_confirm_btn","msg":"取消"});
        var a_sure = this.createdom({"tag":"a","classname":"tippop_confirm_btn","msg":"确定"});
        elmc.appendChild(a_cal),elmc.appendChild(a_sure);
        elma.appendChild(elmb),elma.appendChild(elmc);
        document.body.appendChild(elma);
        var elm_bg = this.createdom({"tag":"div","classname":"tippop_bg"});
        document.body.appendChild(elm_bg);
        a_cal.addEventListener('click',function(){
            elm_bg.remove();
            elma.remove();
        },false);
        a_sure.addEventListener('click',function(){
            elm_bg.remove();
            elma.remove();
            options.callback && options.callback();
        },false);
    },
    createdom:function(options){
        var dom = document.createElement(options.tag);
        dom.className = options.classname;
        if(options.msg){
            dom.innerHTML = options.msg;
        };
        return dom;
    }
};
function getRequest(){
    var url = window.location.search,
        theRequest = {},
        str = '',
        para = [];
    if (url.indexOf("?") != -1) {
        str = url.substr(1);
        strs = str.split("&");
        for(var i = 0, len = strs.length; i < len; i ++) {
            para = strs[i].split("=");
            //decodeURI()、decodeURIComponent
            theRequest[para[0]] = decodeURIComponent( (para.length>=2)?para[1]:"");
        }
    }
    return theRequest;
};

/**
 * A simple, efficent mobile slider solution
 * @author ZhangShaoHua at 2017/4/24
 * @email 577056210@qq.com（low）
 *
 * @LICENSE https://github.com/zhangred/jseffect
 */

function dataSelect(option){
    this.opt = option;
    this.setting();
    this.render();
    this.bindEvent();
    return this;
}
dataSelect.prototype = {
    setting:function(){
        var opt = this.opt;
        this.data = opt.data;
        this.fieldshow = opt.fieldshow;
        this.fieldvalue = opt.fieldvalue;
        this.default_v = opt.default_v?opt.default_v:this.data[0][opt.fieldvalue];
        this.unit = opt.unit?opt.unit:40;
        this.target = opt.target;
        this.maxY = -(this.data.length-3)*this.unit;
        this.Y = 0;
        this.fy = this.ly = this.ofy = 0;
        this.v = null;
    },
    render:function(){
        this.outer = this.createdom({"tag":"div","classname":"select_data_box"});
        this.target.appendChild(this.outer);

        this.scul = this.createdom({"tag":"ul","classname":"sc-ul"});
        this.scul.style.webkitTransition = "all .3s";

        var len = this.data.length,fieldshow = this.fieldshow,default_v = this.default_v,unit = this.unit,fieldvalue = this.fieldvalue;
        for(var i=0;i<len;i++){
            var v = this.data[i];
            var li = this.createdom({"tag":"li","classname":"sc-option","msg":v[fieldshow]});
            if(v[fieldvalue] == default_v){
                this.Y = (2-i)*unit;
                if(this.opt.default_v){this.v = v};
                this.scul.style.webkitTransform = 'translateZ(0) translateY('+((2-i)*unit)+'px)';
                this.opt.change && this.opt.change(v);
            };
            this.scul.appendChild(li);
        }
        this.outer.appendChild(this.scul);
    },
    createdom:function(options){
        var dom = document.createElement(options.tag);
        dom.className = options.classname;
        if(options.msg){
            dom.innerHTML = options.msg;
        }
        return dom;
    },
    bindEvent:function(){
        var _this = this,scul = this.scul,unit = this.unit,outer = this.outer,fieldshow = this.fieldshow;
        outer.addEventListener('touchstart',function(event){
            scul.style.webkitTransition = "all 0s";
            var touches = event.targetTouches;
            _this.fy = touches[0].pageY;
        },false);
        outer.addEventListener('touchmove',function(event){
            var touches = event.targetTouches;
             _this.ly = touches[0].pageY;
            var cy =  _this.ly-_this.fy;
            scul.style.webkitTransform = 'translateZ(0) translateY('+(_this.Y+cy)+'px)';
            event.preventDefault();
        },false)
        outer.addEventListener('touchend',function(event){
            scul.style.webkitTransition = "all .3s";
            if(_this.ly==0){
                _this.fy =  _this.ly = 0;
                return false;
            }
            _this.Y = Math.round((_this.Y + _this.ly - _this.fy)/unit)*unit;
            if(_this.Y<=_this.maxY){
                _this.Y = _this.maxY;
            }else if(_this.Y>=2*unit){
                _this.Y = 2*unit;
            };
            scul.style.webkitTransform = 'translateZ(0) translateY('+(_this.Y)+'px)';
            _this.fy =  _this.ly = 0;

            var v = _this.data[2-Math.floor(_this.Y/unit)];
            if(v!=_this.v){
                _this.v = v;
                _this.opt.change && _this.opt.change(v); 
            }
        },false);
    }
};
function leftslide(opt){
    this.opt = opt;
    this.setting();
    return this;
};
leftslide.prototype = {
    setting:function(){
        var opt = this.opt;
        this.elms = opt.elms;
        this.devi = opt.devi || 100;
        this.len = this.elms.length;
        for(var i=0;i<this.len;i++){
            // console.log(this.elms[i],i)
            this.bindevent(this.elms[i],i);
        }
    },
    bindevent:function(elm,eq){
        var fy = 0,
            ly = 0,
            sy = 0,
            isd = -1,
            ft = {},
            devi = this.devi;
        elm.addEventListener('touchstart',function(event){
            elm.style.webkitTransition = "all 0s";
            ft = event.targetTouches[0];
            fy = ft.pageX;
        },false);
        elm.addEventListener('touchmove',function(event){
            if(isd==0){
                return false;
            }else if(isd==1){
                var touches = event.targetTouches;
                ly = touches[0].pageX;
                var cy =  ly-fy;
                elm.style.webkitTransform = 'translateZ(0) translateX('+(sy+cy)+'px)';
                event.preventDefault();
            }else{
                var touches = event.targetTouches;
                isd = Math.abs(ft.pageX-touches[0].pageX)>Math.abs(ft.pageY-touches[0].pageY)?1:0;
            }
        },false)
        elm.addEventListener('touchend',function(event){
            elm.style.webkitTransition = "all .3s";
            if(ly==0){
                fy =  ly = 0;
                isd = -1;
                return false;
            };
            if(ly-fy+sy<-devi){
                sy = -devi;
                elm.style.webkitTransform = 'translateZ(0) translateX('+(-devi)+'px)';
            }else{
                sy = 0;
                elm.style.webkitTransform = 'translateZ(0) translateX(0)';
            };
            fy =  ly = 0;
            isd = -1;
        },false);
    }
};

var Swipe = function(options){
    this.opt = options;
    this.setting();
}
Swipe.prototype = {
    setting : function(){
        var opt = this.opt;
        this.elm = opt.elm;
        this.interval = opt.interval || 3000;
        this.J_main = this.elm.getElementsByClassName('J_main')[0];
        this.J_main_width = this.J_main.clientWidth;
        this.J_main_fig = this.J_main.getElementsByClassName('J_fig');
        this.maxlen = this.J_main_fig.length-1;
        this.poslen = this.maxlen+1;
        this.renderpos(this.poslen);
        if(this.J_main_fig.length==1){
            return false;
        };
        if(this.J_main_fig.length<3){
            this.J_main.innerHTML += this.J_main.innerHTML;
            this.J_main_fig = this.J_main.getElementsByClassName('J_fig');
            this.maxlen = this.J_main_fig.length-1;
        };

        this.dataindex = 0;
        this.rendermain();
        this.rendervice();
    },
    renderpos:function(len){
        this.popar = this.createdom({"tag":"div","classname":"pos"});
        var str = '';
        for(var i=0;i<len;i++){
            str +='<span class="po"></span>';
        };
        this.popar.innerHTML = str;
        this.elm.appendChild(this.popar);
        this.pos = this.popar.getElementsByClassName('po');
        this.pos[0].setAttribute('class','po po_active');
    },
    createdom:function(options){
        var dom = document.createElement(options.tag);
        dom.className = options.classname;
        if(options.msg){
            dom.innerHTML = options.msg;
        }
        return dom;
    },
    rendermain:function(){
        var width = this.J_main_width,J_main_fig = this.J_main_fig;
        J_main_fig[0].style.webkitTransform = 'translateZ(0) translateX(0)';
        J_main_fig[1].style.webkitTransform = 'translateZ(0) translateX('+width+'px)';
        J_main_fig[this.maxlen].style.webkitTransform = 'translateZ(0) translateX(-'+width+'px)';
        this.bindEvent_main();

    },
    rendervice:function(){
        this.vices = this.elm.getElementsByClassName('J_vice');
        this.vices_len = this.vices.length;
        this.vicesbox = [];
        for(var i=0;i<this.vices_len;i++){
            var obj = {},o = this.vices[i];
            obj.figs = o.getElementsByClassName('J_fig');
            obj.figs_len = obj.figs.length;
            obj.width = o.clientWidth;
            this.vicesbox.push(obj);
        }
    },
    bindEvent_main:function(){
        var _this = this,
            J_main = this.J_main,
            width = this.J_main_width,
            cha = width/5,
            J_main_fig = this.J_main_fig,
            dataindex = this.dataindex,
            maxlen = this.maxlen,
            figs = [J_main_fig[maxlen],J_main_fig[0],J_main_fig[1]],
            fx = 0,
            lx = 0,
            nx = 0,
            intval = '',
            po = null,
            s = null;

        J_main.addEventListener('touchstart',function(event){
            clearInterval(intval);
            for(var i=0;i<3;i++){
                figs[i].style.webkitTransition = "all 0s";
            };
            var touches = event.targetTouches;
            fx = touches[0].pageX;
        },false);
        J_main.addEventListener('touchmove',function(event){
            var touches = event.targetTouches;
             lx = touches[0].pageX;
            var cy =  lx - fx;
            for(var i=0;i<3;i++){
                figs[i].style.webkitTransform = 'translateZ(0) translateX('+((i-1)*width+cy)+'px)';
            };
            event.preventDefault();
        },false)
        J_main.addEventListener('touchend',function(event){
            intval = setInterval(function(){
                goleft();
                goscroll();
            },_this.interval);
            if(lx==0){
                return false;
            };
            if(lx-fx<= -cha){//left
                goleft();
            }else if(lx-fx>=cha){
                po = 1;
                s = dataindex;
                dataindex--;
                if(dataindex<0){
                    dataindex = maxlen;
                };
                _this.changepo(s,dataindex);
                figs.pop();
                figs.reverse();
                var o = J_main_fig[(dataindex-1)<0?maxlen:dataindex-1];
                o.style.webkitTransition = "all 0s";
                o.style.webkitTransform = 'translateZ(0) translateX(-'+width+'px)';
                figs.push(o);
                figs.reverse();
            };
            goscroll();

        },false);
        
        intval = setInterval(function(){
            goleft();
            goscroll();
        },_this.interval);

        function goscroll(){
            setTimeout(function(){
                lx = 0;
                for(var i=0;i<3;i++){
                    figs[i].style.webkitTransition = "all .3s";
                    figs[i].style.webkitTransform = 'translateZ(0) translateX('+((i-1)*width)+'px)';
                };
                if(po!=null){
                    _this.others(po,s,dataindex);
                };
                po = null;
                s = null;
            },20);
        };
        function goleft(){
            po = 0;
            s = dataindex;
            dataindex++;
            if(dataindex>maxlen){
                dataindex = 0;
            };
            _this.changepo(s,dataindex);
            figs.shift();
            var o = J_main_fig[(dataindex+1)>maxlen?0:dataindex+1];
            o.style.webkitTransition = "all 0s";
            o.style.webkitTransform = 'translateZ(0) translateX('+width+'px)';
            figs.push(o);
        };
    },
    others:function(po,s,dataindex){
        var vicesbox = this.vicesbox,
            len = vicesbox.length,
            _this = this;
        for(var i=0;i<len;i++){
            (function(){
                var o = vicesbox[i],f = o.figs[s%_this.poslen],t = o.figs[dataindex%_this.poslen],w = o.width;
                if(po){
                    t.style.webkitTransition = "all 0s";
                    t.style.webkitTransform = 'translateZ(0) translateX(-'+w+'px)';
                    setTimeout(function(){
                        f.style.webkitTransition = "all .3s";
                        f.style.webkitTransform = 'translateZ(0) translateX('+w+'px)';
                        t.style.webkitTransition = "all .3s";
                        t.style.webkitTransform = 'translateZ(0) translateX(0)';
                    },20);
                }else{
                    t.style.webkitTransition = "all 0s";
                    t.style.webkitTransform = 'translateZ(0) translateX('+w+'px)';
                    setTimeout(function(){
                        f.style.webkitTransition = "all .3s";
                        f.style.webkitTransform = 'translateZ(0) translateX(-'+w+'px)';
                        t.style.webkitTransition = "all .3s";
                        t.style.webkitTransform = 'translateZ(0) translateX(0)';
                    },20);
                }
            })()
        }
    },
    changepo:function(f,t){
        this.pos[f%this.poslen].setAttribute('class','po');
        this.pos[t%this.poslen].setAttribute('class','po po_active');
    }
};

function overtouch(opt){
    this.opt = opt;
    this.setting();
    this.bindevent();
    return this;
};
overtouch.prototype = {
    setting:function(){
        var opt = this.opt;
        this.elm = opt.elm;
        this.edge = opt.edge== undefined?10:opt.edge;
    },
    bindevent:function(){
        var elm = this.elm,
            bc = elm.getBoundingClientRect(),
            elm_w = elm.clientWidth,
            ftouch = {"pageX":0,"pageY":0},
            ltouch = {"pageX":bc.left,"pageY":bc.top},
            edge = this.edge,
            wdw = window.innerWidth;
            
        elm.style.cssText = "position:fixed; left:0; top:0; bottom:auto;";
        elm.style.webkitTransform = 'translateZ(0) translate('+bc.left+'px,'+bc.top+'px)';

        elm.addEventListener('touchstart',function(event){
            elm.style.webkitTransition = "all 0s";
            ftouch = event.targetTouches[0];
        },false);
        elm.addEventListener('touchmove',function(event){
            var mtouch = event.targetTouches[0];
            elm.style.webkitTransform = 'translateZ(0) translate('+(mtouch.pageX - ftouch.pageX + ltouch.pageX)+'px,'+(mtouch.pageY - ftouch.pageY + ltouch.pageY)+'px)';
            event.preventDefault();
        },false)
        elm.addEventListener('touchend',function(event){
            elm.style.webkitTransition = "all .3s";
            var lbc = elm.getBoundingClientRect();
            ltouch.pageX = lbc.left<=(wdw/2)?edge:(wdw-edge-elm_w);
            ltouch.pageY = lbc.top;
            
            elm.style.webkitTransform = 'translateZ(0) translate('+(ltouch.pageX)+'px,'+(ltouch.pageY)+'px)';
        },false);
    }
}