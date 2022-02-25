#!/usr/bin/env python
from __future__ import with_statement, division
from Tkinter import Tk, Frame, Button, Canvas, Label, NW
from array import array
from PIL import Image as PILImage, ImageTk, ImageDraw

def tileFromPlanar(s, opaqueBase=0):
    nPlanes = len(s) // 8
    im = PILImage.new('P', (8, 8))
    pixels = im.load()
    if pixels is None:
        print "Ouch!", repr(im)
    for y in range(8):
        planedata = [ord(c) for c in s[y::8]]
        for x in range(8):
            c = 0
            for i in range(nPlanes):
                if planedata[i] & (0x80 >> x):
                    c |= 1 << i
            pixels[x, y] = c + opaqueBase if c > 0 else c
    return im

def renderAttrPicker(tileImg, palette, value):
    im = PILImage.new('P', (128, 32))
    im.putpalette(palette)
    for i in range(4):
        x = i * 32
        t = 0 if i == value else 3
        im.paste(i * 4 + 1, (x + 16, t, x + 32 - t, 16))
        im.paste(i * 4 + 2, (x + t, 16, x + 16, 32 - t))
        im.paste(i * 4 + 3, (x + 16, 16, x + 32 - t, 32 - t))
    im.paste(tileImg.resize((16, 16)), (value * 32, 0))
    #im.show()
    return im

def renderChrFile(tiledata, palette, opaqueBase=0):
    tiles = [tiledata[i:i + 16] for i in range(0, len(tiledata), 16)]
    rows = [tiles[i:i + 16] for i in range(0, len(tiles), 16)]
    h = len(rows) * 8
    w = 128

    im = PILImage.new('P', (w, h))
    y = 0
    #palette = [0, 0, 0, 153, 102, 0, 102, 204, 0, 255, 204, 0]
    im.putpalette(palette)
    for row in rows:
        x = 0
        for tiledata in row:
            tile = tileFromPlanar(tiledata, opaqueBase)
            im.paste(tile, (x, y))
            x += 8
        y += 8
    return im

class NamFile:
    defaultNESPalette = \
        "\x0f\x00\x10\x30\x0f\x12\x1a\x30\x0f\x1a\x2c\x30\x0f\x12\x14\x30"
    nesclut = [
        (0x80,0x80,0x80), (0x00,0x00,0xBB), (0x37,0x00,0xBF), (0x84,0x00,0xA6),
        (0xBB,0x00,0x6A), (0xB7,0x00,0x1E), (0xB3,0x00,0x00), (0x91,0x26,0x00),
        (0x7B,0x2B,0x00), (0x00,0x3E,0x00), (0x00,0x48,0x0D), (0x00,0x3C,0x22),
        (0x00,0x2F,0x66), (0x00,0x00,0x00), (0x05,0x05,0x05), (0x05,0x05,0x05),

        (0xC8,0xC8,0xC8), (0x00,0x59,0xFF), (0x44,0x3C,0xFF), (0xB7,0x33,0xCC),
        (0xFF,0x33,0xAA), (0xFF,0x37,0x5E), (0xFF,0x37,0x1A), (0xD5,0x4B,0x00),
        (0xC4,0x62,0x00), (0x3C,0x7B,0x00), (0x1E,0x84,0x15), (0x00,0x95,0x66),
        (0x00,0x84,0xC4), (0x11,0x11,0x11), (0x09,0x09,0x09), (0x09,0x09,0x09),

        (0xFF,0xFF,0xFF), (0x00,0x95,0xFF), (0x6F,0x84,0xFF), (0xD5,0x6F,0xFF),
        (0xFF,0x77,0xCC), (0xFF,0x6F,0x99), (0xFF,0x7B,0x59), (0xFF,0x91,0x5F),
        (0xFF,0xA2,0x33), (0xA6,0xBF,0x00), (0x51,0xD9,0x6A), (0x4D,0xD5,0xAE),
        (0x00,0xD9,0xFF), (0x66,0x66,0x66), (0x0D,0x0D,0x0D), (0x0D,0x0D,0x0D),

        (0xFF,0xFF,0xFF), (0x84,0xBF,0xFF), (0xBB,0xBB,0xFF), (0xD0,0xBB,0xFF),
        (0xFF,0xBF,0xEA), (0xFF,0xBF,0xCC), (0xFF,0xC4,0xB7), (0xFF,0xCC,0xAE),
        (0xFF,0xD9,0xA2), (0xCC,0xE1,0x99), (0xAE,0xEE,0xB7), (0xAA,0xF7,0xEE),
        (0xB3,0xEE,0xFF), (0xDD,0xDD,0xDD), (0x11,0x11,0x11), (0x11,0x11,0x11)
    ]

    def __init__(self, chrfilename, palfilename='', namfilename=None):
        self.loadchr(chrfilename)
        self.loadpal(palfilename)
        self.loadnam(namfilename)

    def loadchr(self, chrfilename):
        with open(chrfilename, 'rb') as infp:
            chrdata = infp.read(4096)
            self.chrdata = chrdata
        if len(self.chrdata) != 4096:
            raise ValueError("not enough data for pattern table")

    def loadpal(self, palfilename):
        self.palfilename = palfilename
        try:
            with open(palfilename, 'rb') as infp:
                pal = infp.read(16)
            if len(paldata) != 16:
                raise ValueError("not enough data for palette")
        except IOError, e:
            import errno
            if e.errno in (errno.ENOENT, errno.EINVAL):
                pal = self.defaultNESPalette
            else:
                raise
        self.clut = []
        for c in pal:
            self.clut.extend(self.nesclut[ord(c) & 0x3F])
        
    def loadnam(self, namfilename):
        print "namfilename is", namfilename
        if namfilename is not None:
            try:
                with open(namfilename, 'rb') as infp:
                    namdata = infp.read(1152)
                if ((len(namdata) != 1024
                     and namdata.startswith('\x04\x00'))
                    or namfilename.lower().endswith('.pkb')):
                    print "unpacking"
                    namdata = UnPackBits(namdata[2:]).flush().tostring()
                if len(namdata) != 1024:
                    raise ValueError("not enough data for nametable")
                self.namdata = array('B', namdata)
            except IOError, e:
                import errno
                if e.errno == errno.ENOENT:
                    namfilename = None
                else:
                    raise
        if namfilename is None:
            self.namdata = array('B', [0 for i in range(1024)])
        self.namfilename = namfilename
        self.setUnsaved(False)

    def setUnsaved(self, isSaved):
        import datetime
        self.unsaved = (datetime.datetime.now()
                        if isSaved
                        else False)

    def savenam(self, namfilename=None):
        if namfilename is None:
            namfilename = self.namfilename
        s = self.namdata.tostring()
        if namfilename.lower().endswith('.pkb'):
            s = "\x04\x00" + PackBits(s).flush().tostring()
        with open(namfilename, 'wb') as outfp:
            outfp.write(s)
        self.namfilename = namfilename
        self.setUnsaved(False)

    def getTile(self, x, y):
        if x < 0 or x >= 32 or y < 0 or y >= 30:
            return None
        nameIdx = y * 32 + x
        tileNo = self.namdata[nameIdx]
        attrIdx = (y >> 2) * 8 + (x >> 2) + 960
        attrShift = ((y & 0x02) << 1) | (x & 0x02)
        attrNo = (self.namdata[attrIdx] >> attrShift) & 0x03
        return (tileNo, attrNo)

    def setTile(self, x, y, tileNo, attrNo=None):
        if x < 0 or x >= 32 or y < 0 or y >= 30:
            return
        nameIdx = y * 32 + x
        self.namdata[nameIdx] = tileNo
        if attrNo is not None:
            attrIdx = (y >> 2) * 8 + (x >> 2) + 960
            attrShift = ((y & 0x02) << 1) | (x & 0x02)
            attrByte = (attrNo & 0x03) << attrShift
            attrByte |= self.namdata[attrIdx] & ~(0x03 << attrShift)
            self.namdata[attrIdx] = attrByte
    
    def getTileData(self, tileNo):
        return self.chrdata[tileNo * 16:tileNo * 16 + 16]

    def renderTile(self, tileNo, attrNo):
        return tileFromPlanar(self.getTileData(tileNo), attrNo * 4)

def build_menubar(parent, mbardata):
    from Tkinter import Menu
    menubar = Menu(parent)
    parent.config(menu=menubar)
    menus = []
    for (label, items) in mbardata:
        menu = Menu(menubar)
        menus.append(menu)
        menubar.add_cascade(label=label, menu=menu)
        for item in items:
            if item == '-':
                menu.add_separator()
            else:
                label = item[0]
                underline = label.find('&')
                if underline >= 0:
                    label = label[:underline] + label[underline+1:]
                else:
                    underline = None
                accelerator = item[2] if len(item) > 2 else None
                menu.add_command(label=label, command=item[1],
                                 accelerator=accelerator,
                                 underline=underline)
    return (menubar, menus)

class TilePicker(Frame):
    def __init__(self, parent, doc, **kw):
        apply(Frame.__init__, (self, parent), kw)
        self.doc = doc
        self.tilePicker = None
        self.attrPicker = None
        self.status = None
        self.curTile = 0
        self.setAttribute(0)
        self.tilePicker = Label(self, image=self.tilePickerPI,
                                width=128, borderwidth=0)
        self.tilePicker.grid(row=0,column=0)
        self.tilePicker.bind("<Button-1>", self.tilePickerCallback)
        self.attrPicker = Label(self, image=self.attrPickerPI,
                                borderwidth=0)
        self.attrPicker.grid(row=1,column=0)
        self.attrPicker.bind("<Button-1>", self.attrPickerCallback)
        self.status = Label(self)
        self.status.grid(row=2,column=0)
        self.setStatus()

    def setAttribute(self, value):
        self.curAttribute = value & 0x03
        self.updateWidgets()

    def updateWidgets(self):
        self.tilePickerImage = renderChrFile(self.doc.chrdata,
                                             self.doc.clut,
                                             self.curAttribute * 4)
        self.tilePickerPI = ImageTk.PhotoImage(self.tilePickerImage)
        if self.tilePicker is not None:
            self.tilePicker.configure(image=self.tilePickerPI)

        previewTile = self.doc.renderTile(self.curTile, self.curAttribute)
        self.attrPickerImage = renderAttrPicker(previewTile,
                                                self.doc.clut,
                                                self.curAttribute)
        self.attrPickerPI = ImageTk.PhotoImage(self.attrPickerImage)
        if self.attrPicker is not None:
            self.attrPicker.configure(image=self.attrPickerPI)
        
        self.setStatus()

    def setTile(self, tile):
        self.curTile = tile
        self.setAttribute(self.curAttribute)

    def setStatus(self):
        if self.status is None:
            return
        label = "tile $%02x attr %d" % (self.curTile, self.curAttribute)
        self.status.configure(text=label)

    def tilePickerCallback(self, event):
        if event.x >= 0 and event.x < 128 and event.y >= 0 and event.y < 128:
            tileX = event.x // 8
            tileY = event.y // 8
            newTileNo = tileY * 16 + tileX
            #print "mouse was clicked on tile", newTileNo
            self.setTile(newTileNo)
            return
        print "mouse was clicked at (%d, %d)" % (event.x, event.y)

    def attrPickerCallback(self, event):
        if event.x >= 0 and event.x < 128:
            attr = event.x // 32
            #print "mouse was clicked on attribute", attr
            self.setAttribute(attr)
            return
        print "mouse was clicked at (%d, %d)" % (event.x, event.y)

class NamDisplay(Canvas):
    def __init__(self, parent, doc, **kw):
        kw['width'] = 512
        kw['height'] = 480
        kw['relief']='raised'
        kw['highlightthickness'] = 0
        apply(Canvas.__init__, (self, parent), kw)
        self.doc = doc
        self.tile = []
        im = PILImage.new('RGB', (32, 32))
        for y in range(15):
            row = []
            for x in range(16):
                tile = ImageTk.PhotoImage(im)
                if True or ((x ^ y) & 1) == 0:
                    self.create_image(x * 32, y * 32, image=tile, anchor=NW)
                row.append(tile)
            self.tile.append(row)
        self.updating = False
        self.updScreen()

    def updScreen(self):
        self.updating = True
        for y in range(0, 30, 2):
            for x in range(0, 32, 2):
                self.updTile(x, y)
        self.updating = False
        self.update_idletasks()

    def updTile(self, x, y):
        if x < 0 or x >= 32 or y < 0 or y >= 30:
            return
        y = y & ~1
        x = x & ~1
        im = PILImage.new('RGB', (32, 32))
        dst = self.tile[y >> 1][x >> 1]
        for y1 in range(2):
            for x1 in range(2):
                (tileNo, attrNo) = self.doc.getTile(x + x1, y + y1)
                tile = self.doc.renderTile(tileNo, attrNo).resize((16, 16))
                tile.putpalette(self.doc.clut)
                im.paste(tile, (x1 * 16, y1 * 16))
        dst.paste(im)
        if not self.updating:
            self.update_idletasks()

class PackBits():
    def __init__(self, toWrite=''):
        self.bytes = array('b')
        self.closed = False
        self.mode = 'wb'
        self.name = '<PackBits>'
        self.newlines = None
        if toWrite:
            self.write(toWrite)

    def close(self):
        self.bytes = None
        self.closed = True

    def write(self, s):
        """Add a string to the buffer."""
        if not self.closed:
            self.bytes.fromstring(s)

    def tell(self):
        return len(self.bytes)

    def truncate(self, length):
        if not self.closed:
            del self[length:]

    def writelines(self, seq):
        """Add a sequence of strings to the buffer."""
        self.write(''.join(seq))

    def flush(self):
        """Compress the data to a file."""
        i = 0
        base = 0
        out = array('b')
        while base < len(self.bytes):

            # measure the run starting at t
            i = 1
            imax = min(128, len(self.bytes) - base)
            basebyte = self.bytes[base]
            while (i < imax
                   and basebyte == self.bytes[base + i]):
                i += 1
            # if the run is either length 3 or to the end of the file,
            # write it
            if i > 2 or base + i == len(self.bytes):
                out.append(1 - i)
                out.append(self.bytes[base])
                base += i
                continue

            # measure the nonrun starting at t
            i = 1
            imax = min(128, len(self.bytes) - base)
            while (i < imax
                   and (base + i + 2 >= len(self.bytes)
                        or self.bytes[base + i] != self.bytes[base + i + 1]
                        or self.bytes[base + i] != self.bytes[base + i + 2])):
                i += 1
            out.append(i - 1)
            out.extend(self.bytes[base:base + i])
            base += i
        return out

    @staticmethod
    def test():
        pb = PackBits('stopping stoppping stopppppi')
        data = pb.flush()
        print repr(data)

class UnPackBits(PackBits):
    def flush(self):
        out = array('b')
        base = 0
        while base < len(self.bytes):
            c = self.bytes[base]
            if c > 0 and c <= 127:
                b = self.bytes[base + 1]
                out.extend(self.bytes[base + 1:base + c + 2])
                base += 2 + c
            elif c >= -127:
                b = self.bytes[base + 1]
                out.fromlist([b] * (1 - c))
                base += 2
        return out

    @staticmethod
    def test():
        start = 'stopping stoppping stopppppi'
        packed = PackBits(start).flush().tostring()
        print repr(packed)
        unpacked = UnPackBits(packed).flush().tostring()
        print repr(unpacked)
        print "pass" if start == unpacked else "fail"
        

class App:
    filetypes = [
        ('NES nametable', '*.nam'),
        ('NES compressed nametable', '*.pkb'),
        ('PNG image', '*.png'),
        ('GIF image', '*.gif'),
        ('Windows bitmap', '*.bmp')
    ]

    def __init__(self, w, doc):
        import sys
        self.window = w
        self.doc = doc
        mbardata = [
            ("File", [
                ("&New Nametable", lambda: self.file_new_nam(), "Ctrl+N"),
                ("&Open Nametable...", lambda: self.file_open_nam(), "Ctrl+O"),
                ("Open &Pattern Table...", lambda: self.file_open_chr(), "Ctrl+L"),
                '-',
                ("&Save", lambda: self.file_save_nam(), "Ctrl+S"),
                ("Save &As...", lambda: self.file_save_nam_as(), "Ctrl+A"),
                '-',
                ("E&xit", lambda: self.file_quit(), "Ctrl+Q")
            ]),
            ("Help", [
                ("&About...", lambda: self.about())
            ])
        ]
        (menubar, menus) = build_menubar(w, mbardata)
        w.bind("<Control-n>", lambda e: self.file_new_nam())
        w.bind("<Control-N>", lambda e: self.file_new_nam())
        w.bind("<Control-o>", lambda e: self.file_open_nam())
        w.bind("<Control-O>", lambda e: self.file_open_nam())
        w.bind("<Control-l>", lambda e: self.file_open_chr())
        w.bind("<Control-L>", lambda e: self.file_open_chr())
        w.bind("<Control-s>", lambda e: self.file_save_nam())
        w.bind("<Control-S>", lambda e: self.file_save_nam())
        w.bind("<Control-q>", lambda e: self.file_quit())
        w.bind("<Control-Q>", lambda e: self.file_quit())

        self.tilePicker = TilePicker(w, doc)
        self.tilePicker.grid(row=0,column=0, sticky=NW)
        self.namDisplay = NamDisplay(w, doc, borderwidth=0)
        self.namDisplay.grid(row=0,column=1)
        self.namDisplay.bind("<Control-Button-1>", self.namPickupCallback)
        self.namDisplay.bind("<Control-B1-Motion>", self.namPickupCallback)
        self.namDisplay.bind("<Button-1>", self.namWriteCallback)
        self.namDisplay.bind("<B1-Motion>", self.namWriteCallback)
        w.wm_resizable(0,0)
        self.updWindowTitle()

    def namPickupCallback(self, event):
        if event.x >= 0 and event.x < 512 and event.y >= 0 and event.y < 512:
            x = event.x // 16
            y = event.y // 16
            (tile, attribute) = self.doc.getTile(x, y)
            self.tilePicker.curTile = tile
            self.tilePicker.setAttribute(attribute)
            return
        
    def namWriteCallback(self, event):
        if event.x >= 0 and event.x < 512 and event.y >= 0 and event.y < 512:
            x = event.x // 16
            y = event.y // 16
            t = self.tilePicker.curTile
            a = self.tilePicker.curAttribute
            self.doc.setTile(x, y, t, a)
            if not self.doc.unsaved:
                self.doc.setUnsaved(True)
                self.updWindowTitle()
            self.namDisplay.updTile(x, y)
            return

    def updWindowTitle(self):
        nfn = self.doc.namfilename
        if nfn is None:
            nfn = 'untitled'
        if self.doc.unsaved:
            nfn = '*' + nfn
        appname = '8name II'
        title = ' - '.join((nfn, appname))
        self.window.title(title)
        
    def file_new_nam(self):
        print "File > New Nametable"

    def file_open_nam(self):
        from tkFileDialog import askopenfilename
        filename = askopenfilename(parent=root,
                                   filetypes=self.filetypes,
                                   initialfile=self.doc.namfilename,
                                   title="Open Nametable")
        print "file open nam: filename is", filename
        if not isinstance(filename, basestring):
            return
        self.doc.loadnam(filename)
        self.namDisplay.updScreen()
        self.updWindowTitle()

    def file_open_chr(self):
        from tkFileDialog import askopenfilename
        filename = askopenfilename(parent=root,
                                   filetypes=[('Pattern Table', '*.chr')],
                                   initialfile=self.doc.namfilename,
                                   title="Open Pattern Table")
        if not isinstance(filename, str):
            return
        self.doc.loadchr(filename)
        self.tilePicker.updateWidgets()
        self.namDisplay.updScreen()

    def file_save_nam(self):
        if self.doc.namfilename is None:
            return self.file_save_nam_as()
        self.doc.savenam()
        self.updWindowTitle()

    def file_save_nam_as(self):
        from tkFileDialog import asksaveasfilename
        filename = asksaveasfilename(parent=root,
                                     filetypes=self.filetypes,
                                     title="Save Nametable As")
        ext = filename[-4:].lower()
        if ext in ('.png', '.gif', '.bmp'):
            print "Would save image to", filename
        else:
            self.doc.savenam(filename)
        self.updWindowTitle()

    def file_quit(self):
        self.window.destroy()

root = Tk()
app = App(root, NamFile('../spritecans.chr'))
root.mainloop()
print "remain:"
print "1. implement image saving"
print "2. implement and test loading"
print "3. implement and test compressed pkb support"
print "4. Implement stub methods for File menu items"
print "5. Warn on closing document where doc.unsaved is not False"
print "6. Write palette editor"
