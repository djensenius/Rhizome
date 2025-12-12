import sys
from pbxproj import XcodeProject

def add_file_to_target(project_path, file_path, target_name):
    project = XcodeProject.load(project_path)
    
    # Find the target
    target = project.get_target_by_name(target_name)
    if not target:
        print(f"Target '{target_name}' not found.")
        return

    # Add the file to the project (if not already there, but it is)
    # We just need to add it to the target's build phase
    
    # pbxproj's add_file automatically adds to the main group if not specified, 
    # and can add to targets.
    # Since the file is already in the project, we should try to find its file_ref first?
    # Or just call add_file and let it handle it (it might duplicate if not careful).
    
    # Better: use add_file with force=False?
    # But we want to add it to a specific target.
    
    project.add_file(file_path, target_name=target_name)
    
    project.save()
    print(f"Added '{file_path}' to target '{target_name}'.")

if __name__ == "__main__":
    add_file_to_target("Rhizome.xcodeproj/project.pbxproj", "Rhizome/Theme.swift", "RhizomeUITests")
