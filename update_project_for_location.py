#!/usr/bin/env python3
import re

# Read the project file
with open('PriceMateCanada.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Check if LocationManager.swift is already in the project
if 'LocationManager.swift' in content:
    print("LocationManager.swift already exists in project")
else:
    # Add LocationManager.swift file reference
    file_ref = '\t\t4A12346B1ABC123400000000 /* LocationManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LocationManager.swift; sourceTree = "<group>"; };'
    
    # Find where to insert the file reference (after DataModel.xcdatamodeld)
    insert_pos = content.find('4A1234691ABC123400000000 /* DataModel.xcdatamodeld */ = {isa = PBXFileReference')
    if insert_pos == -1:
        # If DataModel not found, insert after CoreDataStack
        insert_pos = content.find('4A1234671ABC123400000000 /* CoreDataStack.swift */ = {isa = PBXFileReference')
    insert_pos = content.find('};', insert_pos) + 3
    content = content[:insert_pos] + '\n' + file_ref + content[insert_pos:]
    
    # Add to PBXBuildFile section
    build_file = '\t\t4A12346C1ABC123400000000 /* LocationManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 4A12346B1ABC123400000000 /* LocationManager.swift */; };'
    
    # Find where to insert the build file (after DataModel.xcdatamodeld)
    insert_pos = content.find('4A12346A1ABC123400000000 /* DataModel.xcdatamodeld in Sources */')
    if insert_pos == -1:
        # If DataModel not found, insert after CoreDataStack
        insert_pos = content.find('4A1234681ABC123400000000 /* CoreDataStack.swift in Sources */')
    insert_pos = content.find('};', insert_pos) + 3
    content = content[:insert_pos] + '\n' + build_file + content[insert_pos:]
    
    # Add to PBXGroup children
    group_pattern = r'(4A1234691ABC123400000000 /\* DataModel\.xcdatamodeld \*/,)'
    replacement = r'\1\n\t\t\t\t4A12346B1ABC123400000000 /* LocationManager.swift */,'
    content = re.sub(group_pattern, replacement, content)
    
    # Add to Sources build phase
    sources_pattern = r'(4A12346A1ABC123400000000 /\* DataModel\.xcdatamodeld in Sources \*/,)'
    replacement = r'\1\n\t\t\t\t4A12346C1ABC123400000000 /* LocationManager.swift in Sources */,'
    content = re.sub(sources_pattern, replacement, content)
    
    # Write the updated project file
    with open('PriceMateCanada.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)
    
    print("Added LocationManager.swift to project")