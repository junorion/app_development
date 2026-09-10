/* index.html 의 인라인 스크립트를 Node 에서 돌리기 위한 최소 DOM 스텁.
   실제 DOM 의 부수효과(클래스 토글, textContent 비우기 등)까지 흉내내야
   가짜 실패가 나지 않는다. */
class ClassList {
  constructor(el) { this.el = el; this.set = new Set(); }
  add(...c) { c.forEach(x => x && this.set.add(x)); }
  remove(...c) { c.forEach(x => this.set.delete(x)); }
  contains(c) { return this.set.has(c); }
  toggle(c, force) {
    const on = force === undefined ? !this.set.has(c) : !!force;
    if (on) this.set.add(c); else this.set.delete(c);
    return on;
  }
}
class El {
  constructor(tag) {
    this.tagName = (tag || "div").toUpperCase();
    this.children = [];
    this.parentNode = null;
    this.dataset = {};
    this.attrs = {};
    this.classList = new ClassList(this);
    this._text = "";
    this.hidden = false;
    this.disabled = false;
    this.offsetWidth = 10;
    // el.style.width = ... 같은 대입과, CSS 변수를 넣는 setProperty 를 받아 준다
    this.style = {
      _vars: {},
      setProperty(k, v) { this._vars[k] = String(v); },
      getPropertyValue(k) { return this._vars[k] || ""; },
      removeProperty(k) { delete this._vars[k]; },
    };
    this.listeners = {};
  }
  get className() { return [...this.classList.set].join(" "); }
  set className(v) { this.classList.set = new Set(String(v).split(/\s+/).filter(Boolean)); }
  get textContent() {
    return this.children.length ? this.children.map(c => c.textContent).join("") : this._text;
  }
  set textContent(v) { this._text = String(v); this.children.length = 0; }  // 자식을 비운다
  get firstElementChild() { return this.children[0] || null; }
  appendChild(c) { c.parentNode = this; this.children.push(c); return c; }
  append(...cs) { cs.forEach(c => this.appendChild(c)); }
  setAttribute(k, v) { this.attrs[k] = String(v); }
  getAttribute(k) { return k in this.attrs ? this.attrs[k] : null; }
  addEventListener(t, fn) { (this.listeners[t] = this.listeners[t] || []).push(fn); }
  dispatch(t, ev) { (this.listeners[t] || []).forEach(fn => fn(ev || {})); }
  click() { this.dispatch("click", { target: this, preventDefault() {} }); }
  querySelector() { return new El("use"); }
  querySelectorAll() { return []; }
  closest(sel) {
    const want = sel.replace(".", "");
    let n = this;
    while (n) { if (n.classList.contains(want)) return n; n = n.parentNode; }
    return null;
  }
}
function makeDom(ids) {
  const byId = {};
  for (const id of ids) { byId[id] = new El("div"); byId[id].id = id; }
  const doc = {
    documentElement: new El("html"),
    createElement: t => new El(t),
    createDocumentFragment: () => new El("frag"),
    getElementById: id => byId[id] || (byId[id] = new El("div")),
    querySelector: () => null,
    addEventListener: (t, fn) => { (doc.listeners[t] = doc.listeners[t] || []).push(fn); },
    listeners: {},
    hidden: false,
  };
  doc.documentElement.dataset = {};
  return { doc, byId };
}
module.exports = { El, makeDom };
