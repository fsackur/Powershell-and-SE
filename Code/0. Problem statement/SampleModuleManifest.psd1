@{
    Description       = 'Some module that requires other modules.'
    ModuleToProcess   = 'SampleModuleManifest.psm1'
    ModuleVersion     = '99.986986.45'  # and still doesn't bloody work...
    GUID              = '6f566604-f635-4b72-ba28-bcd7194c7fd8'

    Author            = 'Freddie Sackur'
    CompanyName       = 'dustyfox.uk'
    Copyright         = '(c) 2018 Freddie Sackur. Super-copyright.'
    PowerShellVersion = '5.0'

    ScriptsToProcess  = @()
    FormatsToProcess  = @()

    RequiredModules   = @(
        'Foo',                  # String module names are acceptable
        @{
            ModuleName    = 'Bar'      # Or a hashtable specifying a minimum acceptable version
            ModuleVersion = '1.2.3.4'
        },
        @{
            ModuleName      = 'Baz'      # Or you can pin an exact version
            RequiredVersion = '2.3.4.5'
        }
    )

    FunctionsToExport = @(
        'Do-Stuff',
        'Do-OtherStuff'
    )

    PrivateData = @{
        PSData = @{
            Tags = @('Module', 'Dependency')
        }
    }
}
