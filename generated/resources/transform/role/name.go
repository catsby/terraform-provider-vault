package role

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

const nameEndpoint = "/transform/role/{name}"

func NameResource() *schema.Resource {
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
		"name": {
			Type:        schema.TypeString,
			Required:    true,
			Description: "The name of the role.",
			ForceNew:    true,
		},
		"transformations": {
			Type:        schema.TypeList,
			Elem:        &schema.Schema{Type: schema.TypeString},
			Optional:    true,
			Description: "A comma separated string or slice of transformations to use.",
		},
	}
	return &schema.Resource{
		Create: createNameResource,
		Update: updateNameResource,
		Read:   readNameResource,
		Exists: resourceNameExists,
		Delete: deleteNameResource,
		Importer: &schema.ResourceImporter{
			State: schema.ImportStatePassthrough,
		},
		Schema: fields,
	}
}
func createNameResource(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*api.Client)
	path := d.Get("path").(string)
	fullPath := util.ParsePath(path, nameEndpoint, d)
	log.Printf("[DEBUG] Creating %q", fullPath)

	data := map[string]interface{}{}
	data["name"] = d.Get("name")
	if v, ok := d.GetOkExists("transformations"); ok {
		data["transformations"] = v
	}

	log.Printf("[DEBUG] Writing %q", fullPath)
	_, err := client.Logical().Write(fullPath, data)
	if err != nil {
		return fmt.Errorf("error writing %q: %s", fullPath, err)
	}
	d.SetId(path)
	log.Printf("[DEBUG] Wrote %q", fullPath)
	return readNameResource(d, meta)
}

func readNameResource(d *schema.ResourceData, meta interface{}) error {
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
	if val, ok := resp.Data["transformations"]; ok {
		if err := d.Set("transformations", val); err != nil {
			return fmt.Errorf("error setting state key 'transformations': %s", err)
		}
	}
	return nil
}

func updateNameResource(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*api.Client)
	path := d.Id()
	fullPath := util.ParsePath(path, nameEndpoint, d)
	log.Printf("[DEBUG] Updating %q", fullPath)

	data := map[string]interface{}{}
	if d.HasChange("transformations") {
		data["transformations"] = d.Get("transformations")
	}
	defer func() {
		d.SetId(path)
	}()
	_, err := client.Logical().Write(fullPath, data)
	if err != nil {
		return fmt.Errorf("error updating template auth backend role %q: %s", fullPath, err)
	}
	log.Printf("[DEBUG] Updated %q", fullPath)
	return readNameResource(d, meta)
}

func deleteNameResource(d *schema.ResourceData, meta interface{}) error {
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

func resourceNameExists(d *schema.ResourceData, meta interface{}) (bool, error) {
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
