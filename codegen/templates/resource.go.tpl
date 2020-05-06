package {{ .DirName }}
// DO NOT EDIT
// This code is generated.

import (
	"fmt"
	"log"
	"strings"

	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/hashicorp/vault/api"
	"github.com/terraform-providers/terraform-provider-vault/util"
)

{{- if .SupportsWrite }}
const {{ .LowerCaseDifferentiator }}Endpoint = "{{ .Endpoint }}"
{{- else }}
// This resource supports "{{ .Endpoint }}".
{{ end }}

func {{ .UpperCaseDifferentiator }}Resource() *schema.Resource {
	fields := map[string]*schema.Schema{
		"path": {
			Type:        schema.TypeString,
			Required:    true,
			ForceNew:    true,
			Description: "Path to backend to configure.",
			StateFunc: func(v interface{}) string {
				return strings.Trim(v.(string), "/")
			},
		},
		{{- range .Parameters }}
		"{{ .Name }}": {
			{{- if (eq .Schema.Type "string") }}
			Type:        schema.TypeString,
			{{- end }}
			{{- if (eq .Schema.Type "boolean") }}
			Type:        schema.TypeBool,
			{{- end }}
			{{- if (eq .Schema.Type "integer") }}
			Type:        schema.TypeInt,
			{{- end }}
			{{- if (eq .Schema.Type "array") }}
			Type:        schema.TypeList,
			Elem:        &schema.Schema{Type: schema.TypeString},
			{{- end }}
			{{- if .Required }}
			Required:    true,
			{{- else }}
			Optional:    true,
			{{- end }}
			{{- if .Schema.DisplayAttrs.Sensitive }}
			Sensitive:   true,
			{{- end }}
			Description: "{{ .Description }}",
			{{- if .IsPathParam }}
			ForceNew: true,
			{{- end}}
		},
		{{- end }}
	}
	return &schema.Resource{
		{{- if .SupportsWrite }}
		Create: create{{ .UpperCaseDifferentiator }}Resource,
		Update: update{{ .UpperCaseDifferentiator }}Resource,
		{{- end }}
		{{- if .SupportsRead }}
		Read:   read{{ .UpperCaseDifferentiator }}Resource,
		Exists: resource{{ .UpperCaseDifferentiator }}Exists,
		{{- end }}
		{{- if .SupportsDelete }}
		Delete: delete{{ .UpperCaseDifferentiator }}Resource,
		{{- end }}
		Importer: &schema.ResourceImporter{
			State: schema.ImportStatePassthrough,
		},
		Schema: fields,
	}
}

{{- if .SupportsWrite }}
func create{{ .UpperCaseDifferentiator }}Resource(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*api.Client)
	path := d.Get("path").(string)
	fullPath := util.ParsePath(path, nameEndpoint, d)
	log.Printf("[DEBUG] Creating %q", fullPath)

	data := map[string]interface{}{}
	{{- range .Parameters }}
	{{- if .IsPathParam}}
	    data["{{ .Name }}"] = d.Get("{{ .Name }}")
	{{- else }}
	if v, ok := d.GetOkExists("{{ .Name }}"); ok {
		data["{{ .Name }}"] = v
	}
	{{- end }}
	{{- end }}

	log.Printf("[DEBUG] Writing %q", fullPath)
	_, err := client.Logical().Write(fullPath, data)
	if err != nil {
		return fmt.Errorf("error writing %q: %s", fullPath, err)
	}
	d.SetId(path)
	log.Printf("[DEBUG] Wrote %q", fullPath)
	return read{{ .UpperCaseDifferentiator }}Resource(d, meta)
}
{{ end }}

{{- if .SupportsRead }}
func read{{ .UpperCaseDifferentiator }}Resource(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*api.Client)
	path := d.Id()
	fullPath := util.ParsePath(path, nameEndpoint, d)
	log.Printf("[DEBUG] Reading %q", fullPath)

	resp, err := client.Logical().Read(fullPath)
	if err != nil {
		return fmt.Errorf("error reading %q: %s", fullPath, err)
	}
	log.Printf("[DEBUG] Read %q", fullPath)
	if resp == nil {
		log.Printf("[WARN] %q not found, removing from state", fullPath)
		d.SetId("")
		return nil
	}
	{{- range .Parameters }}
	{{- if not .IsPathParam }}
	if val, ok := resp.Data["{{ .Name }}"]; ok {
        if err := d.Set("{{ .Name }}", val); err != nil {
            return fmt.Errorf("error setting state key '{{ .Name }}': %s", err)
        }
    }
    {{- end }}
	{{- end }}
	return nil
}
{{ end }}

{{- if .SupportsWrite }}
func update{{ .UpperCaseDifferentiator }}Resource(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*api.Client)
	path := d.Id()
	fullPath := util.ParsePath(path, nameEndpoint, d)
	log.Printf("[DEBUG] Updating %q", fullPath)

	data := map[string]interface{}{}
	{{- range .Parameters }}
	{{- if not .IsPathParam}}
	if d.HasChange("{{ .Name }}") {
		data["{{ .Name }}"] = d.Get("{{ .Name }}")
	}
	{{- end}}
	{{- end }}
	defer func() {
		d.SetId(path)
	}()
	_, err := client.Logical().Write(fullPath, data)
	if err != nil {
		return fmt.Errorf("error updating template auth backend role %q: %s", fullPath, err)
	}
	log.Printf("[DEBUG] Updated %q", fullPath)
	return read{{ .UpperCaseDifferentiator }}Resource(d, meta)
}
{{ end }}

{{- if .SupportsDelete }}
func delete{{ .UpperCaseDifferentiator }}Resource(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*api.Client)
	path := d.Id()
	fullPath := util.ParsePath(path, nameEndpoint, d)
	log.Printf("[DEBUG] Deleting %q", fullPath)

	_, err := client.Logical().Delete(fullPath)
	if err != nil && !util.Is404(err) {
		return fmt.Errorf("error deleting %q", fullPath)
	} else if err != nil {
		log.Printf("[DEBUG] %q not found, removing from state", fullPath)
		d.SetId("")
		return nil
	}
	log.Printf("[DEBUG] Deleted template auth backend role %q", fullPath)
	return nil
}
{{ end }}

{{- if .SupportsRead }}
func resource{{ .UpperCaseDifferentiator }}Exists(d *schema.ResourceData, meta interface{}) (bool, error) {
	client := meta.(*api.Client)
	path := d.Id()
	fullPath := util.ParsePath(path, nameEndpoint, d)
	log.Printf("[DEBUG] Checking if %q exists", fullPath)

	resp, err := client.Logical().Read(fullPath)
	if err != nil {
		return true, fmt.Errorf("error checking if %q exists: %s", fullPath, err)
	}
	log.Printf("[DEBUG] Checked if %q exists", fullPath)
	return resp != nil, nil
}
{{- end }}
