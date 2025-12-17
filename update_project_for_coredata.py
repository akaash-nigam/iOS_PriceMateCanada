#!/usr/bin/env python3
import re

# Read the project file
with open('PriceMateCanada.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Check if CoreDataStack.swift is already in the project
if 'CoreDataStack.swift' in content:
    print("CoreDataStack.swift already exists in project")
else:
    # Add CoreDataStack.swift file reference
    file_ref = '\t\t4A1234671ABC123400000000 /* CoreDataStack.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CoreDataStack.swift; sourceTree = "<group>"; };'
    
    # Add DataModel.xcdatamodeld file reference
    data_model_ref = '\t\t4A1234691ABC123400000000 /* DataModel.xcdatamodeld */ = {isa = PBXFileReference; lastKnownFileType = wrapper.xcdatamodeld; path = DataModel.xcdatamodeld; sourceTree = "<group>"; };'
    
    # Find where to insert the file reference (after BarcodeScanner.swift)
    insert_pos = content.find('4A1234651ABC123400000000 /* BarcodeScanner.swift */ = {isa = PBXFileReference')
    insert_pos = content.find('};', insert_pos) + 3
    content = content[:insert_pos] + '\n' + file_ref + '\n' + data_model_ref + content[insert_pos:]
    
    # Add to PBXBuildFile section
    build_file = '\t\t4A1234681ABC123400000000 /* CoreDataStack.swift in Sources */ = {isa = PBXBuildFile; fileRef = 4A1234671ABC123400000000 /* CoreDataStack.swift */; };'
    build_file2 = '\t\t4A12346A1ABC123400000000 /* DataModel.xcdatamodeld in Sources */ = {isa = PBXBuildFile; fileRef = 4A1234691ABC123400000000 /* DataModel.xcdatamodeld */; };'
    
    insert_pos = content.find('4A1234661ABC123400000000 /* BarcodeScanner.swift in Sources */')
    insert_pos = content.find('};', insert_pos) + 3
    content = content[:insert_pos] + '\n' + build_file + '\n' + build_file2 + content[insert_pos:]
    
    # Add to PBXGroup children
    group_pattern = r'(4A1234651ABC123400000000 /\* BarcodeScanner\.swift \*/,)'
    replacement = r'\1\n\t\t\t\t4A1234671ABC123400000000 /* CoreDataStack.swift */,\n\t\t\t\t4A1234691ABC123400000000 /* DataModel.xcdatamodeld */,'
    content = re.sub(group_pattern, replacement, content)
    
    # Add to Sources build phase
    sources_pattern = r'(4A1234661ABC123400000000 /\* BarcodeScanner\.swift in Sources \*/,)'
    replacement = r'\1\n\t\t\t\t4A1234681ABC123400000000 /* CoreDataStack.swift in Sources */,\n\t\t\t\t4A12346A1ABC123400000000 /* DataModel.xcdatamodeld in Sources */,'
    content = re.sub(sources_pattern, replacement, content)
    
    # Write the updated project file
    with open('PriceMateCanada.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)
    
    print("Added CoreDataStack.swift and DataModel.xcdatamodeld to project")