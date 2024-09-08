# We define the build_deps_hash function that takes no parameters and returns a hash containing
# the build information for the dependency libraries we wish to build.
def build_deps_hash()
    return {
        # Dependency library we want to build (this is a name we can reference elsewhere)
        # This allows us to name the library and reference it later independant of its version
        # number as we maintain and upgrade our dependencies throughout the projects lifetime.
        'zlib' => {
            # The relative path to the library we want to build
            path: 'zlib-X.Y.Z',
            # The output path to the library we can use the ${pwd} placeholder to insert the current working directory
            output: '${pwd}/release',
            # The command set to execute to clean the library
            clean: [
                # Strings are executed as standard shell commands.  This allows us to use the libraries standard
                # commands to build the library as desired for our project for ease of maintenance.
                'rm -Rf release',
                'make clean',
            ],
            # The command set to execute to build the library
            build: [
                # We can use the ${output} placeholder to insert the desired output path into our commants
                'configure --prefix="${output}" --64',
                'make',
                'make install',
            ],
        },
        'libpng' => {
            path: 'libpng-X.Y.Z',
            output: '${pwd}/release',
            # This is a list of the libraries that this library depends on; if not built they will be built before this library 
            # If we rebuild the dependenct it will cause a rebuild of this library
            depends: [ 'zlib' ],
            clean: [
                'rm -Rf release',
                'make clean',
            ],
            build: [
                # We can use the EnvSetter class to set environment variables for the subsequent shell commands
                # NOTE: When we set these variables we do have to know/undersstand the relative position of our
                # dependency libraries from each other within our project structure.
                EnvSetter.new('ZLIBLIB', '${pwd}/../${zlib}/release/lib'),
                EnvSetter.new('ZLIBINC', '${pwd}/../${zlib}/release/include'),
                'configure --prefix="${output}"',
                'make',
                'make install',
            ],
        },
    }
end
