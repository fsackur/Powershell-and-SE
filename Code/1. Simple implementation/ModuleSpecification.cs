// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Management.Automation.Language;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using System.Management.Automation.Internal;
using Dbg = System.Management.Automation.Diagnostics;



namespace Microsoft.PowerShell.Commands
{
    /// <summary>
    /// Represents module specification written in a module manifest (i.e. in RequiredModules member/field).
    ///
    /// Module manifest allows 2 forms of module specification:
    /// 1. string - module name
    /// 2. hashtable - [string]ModuleName (required) + [Version]ModuleVersion/RequiredVersion (required) + [Guid]GUID (optional)
    ///
    /// so we have a constructor that takes a string and a constructor that takes a hashtable
    /// (so that LanguagePrimitives.ConvertTo can cast a string or a hashtable to this type)
    /// </summary>
    public class ModuleSpecification
    {
        /// <summary>
        /// Default constructor.
        /// </summary>
        public ModuleSpecification()
        {
        }

        /// <summary>
        /// Construct a module specification from the module name.
        /// </summary>
        /// <param name="moduleName">The module name.</param>
        public ModuleSpecification(string moduleName)
        {
            if (string.IsNullOrEmpty(moduleName))
            {
                throw new ArgumentNullException(nameof(moduleName));
            }

            this.Name = moduleName;
            // Alias name of miniumVersion
            this.Version = null;
            this.RequiredVersion = null;
            this.MaximumVersion = null;
            this.Guid = null;
        }

        /// <summary>
        /// Construct a module specification from a hashtable.
        /// Keys can be ModuleName, ModuleVersion, and Guid.
        /// ModuleName must be convertible to <see cref="string"/>.
        /// ModuleVersion must be convertible to <see cref="Version"/>.
        /// Guid must be convertible to <see cref="Guid"/>.
        /// </summary>
        /// <param name="moduleSpecification">The module specification as a hashtable.</param>
        public ModuleSpecification(Hashtable moduleSpecification)
        {
            if (moduleSpecification == null)
            {
                throw new ArgumentNullException(nameof(moduleSpecification));
            }

            var exception = ModuleSpecificationInitHelper(this, moduleSpecification);
            if (exception != null)
            {
                throw exception;
            }
        }

        internal ModuleSpecification(PSModuleInfo moduleInfo)
        {
            if (moduleInfo == null)
            {
                throw new ArgumentNullException(nameof(moduleInfo));
            }

            this.Name = moduleInfo.Name;
            this.Version = moduleInfo.Version;
            this.Guid = moduleInfo.Guid;
        }


        /// <summary>
        /// The module name.
        /// </summary>
        public string Name { get; internal set; }

        /// <summary>
        /// The module GUID, if specified.
        /// </summary>
        public Guid? Guid { get; internal set; }

        /// <summary>
        /// The module version number if specified, otherwise null.
        /// </summary>
        public Version Version { get; internal set; }

        /// <summary>
        /// The module maxVersion number if specified, otherwise null.
        /// </summary>
        public string MaximumVersion { get; internal set; }

        /// <summary>
        /// The exact version of the module if specified, otherwise null.
        /// </summary>
        public Version RequiredVersion { get; internal set; }
    }
}
