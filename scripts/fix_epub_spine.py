#!/usr/bin/env python3
import sys
import os
import zipfile
import shutil
import tempfile
import xml.etree.ElementTree as ET

def reorder_nav_in_spine(epub_path):
    """
    Moves the navigation document (nav.xhtml) in the EPUB spine
    to appear AFTER the dedication page, instead of at the beginning.
    """
    
    # Create temp directory
    temp_dir = tempfile.mkdtemp()
    
    try:
        # Extract EPUB
        with zipfile.ZipFile(epub_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
            
        # Find OPF file
        container_xml = os.path.join(temp_dir, 'META-INF', 'container.xml')
        ET.register_namespace('', "urn:oasis:names:tc:opendocument:xmlns:container")
        tree = ET.parse(container_xml)
        root = tree.getroot()
        
        ns = {'c': 'urn:oasis:names:tc:opendocument:xmlns:container'}
        rootfile_path = root.find(".//c:rootfile", ns).attrib['full-path']
        opf_path = os.path.join(temp_dir, rootfile_path)
        
        # Parse OPF
        opf_ns = {
            'opf': 'http://www.idpf.org/2007/opf',
            'dc': 'http://purl.org/dc/elements/1.1/'
        }
        for k, v in opf_ns.items():
            ET.register_namespace(k if k != 'opf' else '', v)
            
        tree_opf = ET.parse(opf_path)
        root_opf = tree_opf.getroot()
        manifest = root_opf.find('{http://www.idpf.org/2007/opf}manifest')
        spine = root_opf.find('{http://www.idpf.org/2007/opf}spine')
        
        # 1. Identify IDs
        nav_id = None
        dedication_id = None
        
        # Find Nav ID
        for item in manifest.findall('{http://www.idpf.org/2007/opf}item'):
            props = item.get('properties', '')
            href = item.get('href', '')
            
            if 'nav' in props.split():
                nav_id = item.get('id')
            
            # Find Dedication ID (Pandoc usually maps 2nd file to ch002 if linear)
            # 00-frontmatter -> ch001
            # 01-dedicatoria -> ch002 (or prefacio in book-15)
            if 'ch002.xhtml' in href:
                dedication_id = item.get('id')

        if not nav_id:
            print("Warning: No 'nav' item found.")
            return

        if not dedication_id:
            print("Warning: Could not find 'dedicatoria' file in manifest. Cannot reorder accurately.")
            # Fallback: Don't move if we can't find the anchor
            return

        # 2. Reorder Spine
        nav_itemref = None
        dedication_index = -1
        
        # Find the nav itemref object and its current location
        itemrefs = list(spine.findall('{http://www.idpf.org/2007/opf}itemref'))
        
        for i, itemref in enumerate(itemrefs):
            if itemref.get('idref') == nav_id:
                nav_itemref = itemref
            if itemref.get('idref') == dedication_id:
                dedication_index = i
        
        if nav_itemref is not None and dedication_index != -1:
            # Remove nav from current position
            spine.remove(nav_itemref)
            
            # Since we removed an item, if the nav was BEFORE the dedication, 
            # the dedication index effectively shifts down by 1. 
            # We need to insert AFTER the determination.
            # However, since we are iterating on a snapshot list, let's just use the insert logic carefully.
            
            # Let's verify indexes again on the live object?
            # Easier: Remove first, then find dedication index on the live tree again.
            
            # Re-find dedication index in modified spine
            new_dedication_index = -1
            updated_itemrefs = list(spine.findall('{http://www.idpf.org/2007/opf}itemref'))
            for i, itemref in enumerate(updated_itemrefs):
                 if itemref.get('idref') == dedication_id:
                     new_dedication_index = i
                     break
            
            # Insert nav AFTER dedication
            if new_dedication_index != -1:
                spine.insert(new_dedication_index + 1, nav_itemref)
                print(f"Moved nav '{nav_id}' to index {new_dedication_index + 1} (after '{dedication_id}').")
                tree_opf.write(opf_path, encoding='utf-8', xml_declaration=True)
            else:
                 print("Error: Lost dedication item during reorder.")
        else:
            print(f"Could not find both items in spine. Nav: {nav_itemref}, Dedication Index: {dedication_index}")

        # Repack EPUB
        with zipfile.ZipFile(epub_path, 'w', zipfile.ZIP_DEFLATED) as zip_out:
            for foldername, subfolders, filenames in os.walk(temp_dir):
                for filename in filenames:
                    file_path = os.path.join(foldername, filename)
                    arcname = os.path.relpath(file_path, temp_dir)
                    if arcname == 'mimetype':
                        continue
                    zip_out.write(file_path, arcname)
            zip_out.write(os.path.join(temp_dir, 'mimetype'), 'mimetype', compress_type=zipfile.ZIP_STORED)

    finally:
        shutil.rmtree(temp_dir)

def clean_nav_toc(epub_path):
    """
    Removes the first item from the TOC (nav.xhtml) if it points to the Frontmatter (ch001),
    preventing the 'Title Page' from appearing in the Table of Contents.
    """
    temp_dir = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(epub_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
            
        # Locate nav.xhtml
        container_xml = os.path.join(temp_dir, 'META-INF', 'container.xml')
        ET.register_namespace('', "urn:oasis:names:tc:opendocument:xmlns:container")
        tree = ET.parse(container_xml)
        root = tree.getroot()
        ns = {'c': 'urn:oasis:names:tc:opendocument:xmlns:container'}
        rootfile = root.find(".//c:rootfile", ns).attrib['full-path']
        opf_path = os.path.join(temp_dir, rootfile)
        opf_dir = os.path.dirname(opf_path)
        
        # Parse OPF to find nav href
        opf_ns = {'opf': 'http://www.idpf.org/2007/opf'}
        for k,v in opf_ns.items(): ET.register_namespace(k if k!='opf' else '', v)
        tree_opf = ET.parse(opf_path)
        root_opf = tree_opf.getroot()
        manifest = root_opf.find('{http://www.idpf.org/2007/opf}manifest')
        
        nav_href = None
        for item in manifest.findall('{http://www.idpf.org/2007/opf}item'):
            if 'nav' in item.get('properties', '').split():
                nav_href = item.get('href')
                break
        
        if not nav_href:
            print("Warning: No nav file found to clean.")
            return

        nav_path = os.path.join(opf_dir, nav_href)
        
        # Parse nav.xhtml
        ET.register_namespace('', "http://www.w3.org/1999/xhtml")
        ET.register_namespace('epub', "http://www.idpf.org/2007/ops")
        tree_nav = ET.parse(nav_path)
        root_nav = tree_nav.getroot()
        xhtml_ns = {'h': 'http://www.w3.org/1999/xhtml'}
        
        # Find the main <ol> list
        # Check standard location: body -> nav -> ol
        # We look for nav with epub:type="toc"
        main_nav = None
        for nav in root_nav.findall(".//h:nav", xhtml_ns):
            if nav.get('{http://www.idpf.org/2007/ops}type') == 'toc':
                main_nav = nav
                break
        
        if main_nav is None:
            # Fallback for simple nav
            main_nav = root_nav.find(".//h:nav", xhtml_ns)
            
        if main_nav is not None:
            ol = main_nav.find("h:ol", xhtml_ns)
            if ol is not None:
                # Remove first item if it points to ch001 or looks like the Title
                items = list(ol.findall("h:li", xhtml_ns))
                if items:
                    first_li = items[0]
                    first_a = first_li.find("h:a", xhtml_ns)
                    if first_a is not None:
                        href = first_a.get('href', '')
                        text = "".join(first_a.itertext()).strip()
                        # Condition: Points to ch001 OR text matches book title (A VIDA SECRETA DO CÓDIGO)
                        if 'ch001.xhtml' in href or "Masmorra ASCII" in text or "MASMORRA ASCII" in text:
                            ol.remove(first_li)
                            print(f"Removed TOC item: '{text}' ({href})")
                            tree_nav.write(nav_path, encoding='utf-8', xml_declaration=True)

        # Repack
        with zipfile.ZipFile(epub_path, 'w', zipfile.ZIP_DEFLATED) as zip_out:
            for foldername, subfolders, filenames in os.walk(temp_dir):
                for filename in filenames:
                    fpath = os.path.join(foldername, filename)
                    arcname = os.path.relpath(fpath, temp_dir)
                    if arcname == 'mimetype': continue
                    zip_out.write(fpath, arcname)
            zip_out.write(os.path.join(temp_dir, 'mimetype'), 'mimetype', compress_type=zipfile.ZIP_STORED)

    finally:
        shutil.rmtree(temp_dir)

def fix_metadata(epub_path):
    """
    Ensures dc:title, dc:creator and dc:language are populated in the OPF.
    Pandoc 2.x with custom templates sometimes leaves dc:title empty.
    """
    temp_dir = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(epub_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)

        container_xml = os.path.join(temp_dir, 'META-INF', 'container.xml')
        ET.register_namespace('', "urn:oasis:names:tc:opendocument:xmlns:container")
        tree = ET.parse(container_xml)
        root = tree.getroot()
        ns = {'c': 'urn:oasis:names:tc:opendocument:xmlns:container'}
        rootfile_path = root.find(".//c:rootfile", ns).attrib['full-path']
        opf_path = os.path.join(temp_dir, rootfile_path)

        opf_ns = 'http://www.idpf.org/2007/opf'
        dc_ns = 'http://purl.org/dc/elements/1.1/'
        ET.register_namespace('', opf_ns)
        ET.register_namespace('dc', dc_ns)

        tree_opf = ET.parse(opf_path)
        root_opf = tree_opf.getroot()
        metadata = root_opf.find(f'{{{opf_ns}}}metadata')
        if metadata is None:
            print("Warning: No <metadata> element found in OPF.")
            return

        changed = False

        # Fix dc:title
        title_el = metadata.find(f'{{{dc_ns}}}title')
        if title_el is not None and not (title_el.text or '').strip():
            title_el.text = 'Masmorra ASCII'
            changed = True
            print("Fixed empty dc:title -> 'Masmorra ASCII'")
        elif title_el is None:
            title_el = ET.SubElement(metadata, f'{{{dc_ns}}}title')
            title_el.text = 'Masmorra ASCII'
            changed = True
            print("Added missing dc:title -> 'Masmorra ASCII'")

        # Fix dc:creator
        creator_el = metadata.find(f'{{{dc_ns}}}creator')
        if creator_el is not None and not (creator_el.text or '').strip():
            creator_el.text = 'Kleber de Oliveira Andrade'
            changed = True
            print("Fixed empty dc:creator -> 'Kleber de Oliveira Andrade'")
        elif creator_el is None:
            creator_el = ET.SubElement(metadata, f'{{{dc_ns}}}creator')
            creator_el.text = 'Kleber de Oliveira Andrade'
            changed = True
            print("Added missing dc:creator -> 'Kleber de Oliveira Andrade'")

        # Fix dc:language
        lang_el = metadata.find(f'{{{dc_ns}}}language')
        if lang_el is not None and not (lang_el.text or '').strip():
            lang_el.text = 'pt-BR'
            changed = True
        elif lang_el is None:
            lang_el = ET.SubElement(metadata, f'{{{dc_ns}}}language')
            lang_el.text = 'pt-BR'
            changed = True

        if changed:
            tree_opf.write(opf_path, encoding='utf-8', xml_declaration=True)
            # Repack
            with zipfile.ZipFile(epub_path, 'w', zipfile.ZIP_DEFLATED) as zip_out:
                for foldername, subfolders, filenames in os.walk(temp_dir):
                    for filename in filenames:
                        fpath = os.path.join(foldername, filename)
                        arcname = os.path.relpath(fpath, temp_dir)
                        if arcname == 'mimetype':
                            continue
                        zip_out.write(fpath, arcname)
                zip_out.write(os.path.join(temp_dir, 'mimetype'), 'mimetype',
                              compress_type=zipfile.ZIP_STORED)
        else:
            print("Metadata already populated — no changes.")

    finally:
        shutil.rmtree(temp_dir)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 fix_epub_spine.py <epub_file>")
        sys.exit(1)

    fix_metadata(sys.argv[1])
    reorder_nav_in_spine(sys.argv[1])
    clean_nav_toc(sys.argv[1])
