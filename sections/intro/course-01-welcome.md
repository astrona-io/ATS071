# Welcome To The Course

This course covers the Backstage Catalog domain of the Certified Backstage Associate (CBA) exam. The domain is worth 22% of the exam. The certification uses a multiple-choice examination. This course is independently written teaching material. It does not copy exam questions and does not promise to simulate the exam.

## Who the course is for

The course is for people who use or run a Backstage developer portal and want to understand the software catalog. You do not need to know Backstage already. You should be able to read YAML and use a terminal. By the end you can read and write catalog descriptor files, explain how an entity gets from a file into the catalog, and find out why an entity is missing or wrong.

## What the course covers

The domain has six objectives, and the course has one section for each:

- Understand how and why to use the Backstage catalog: entities, kinds, ownership and relationships.
- Populate the catalog: descriptor files, entity policies and catalog rules.
- Use annotations: how a plugin reads an annotation and what a wrong value does.
- Work with manually registered locations: static locations, Location entities and what happens when you remove one.
- Troubleshoot entity ingestion: the processing stages and where each kind of error appears.
- Work with automated ingestion: entity providers, discovery filters and schedules.

## Words the course uses

An entity is one record in the catalog, such as a service, an API or a team. A descriptor is the YAML file that declares an entity. A location is a pointer to a descriptor file. Ingestion is the work the catalog backend does to read locations and turn their files into entities. An annotation is a metadata key that a plugin or the catalog reads.

## The example estate

The examples use a small fictional estate. The services are `bridge`, `scout`, `shuttle` and `probe`. The teams are groups such as `starfleet-ops`. The names only make examples easy to follow. They have no meaning in Backstage.

## How each section is laid out

Each section starts with an introduction and learning outcomes. Each module has a landing page, a few reading parts, a playground, a graded lab and a summary. Each section ends with a capstone lab and a short quiz. The course ends with a quiz across all sections.

A reading part explains one idea, then shows it with a command or a file you can try in the playground. The playground is a clean environment with no task and no grading. The lab gives a task and checks your result with `astrona submit`. Read the part first, practise in the playground, then take the lab.
